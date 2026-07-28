--- *minidiff_arc* Arc (Arcadia VCS) source for mini.diff
---
--- External add-on for 'echasnovski/mini.diff'. Does NOT modify mini.diff:
--- it only uses the public API (`MiniDiff.set_ref_text`, `MiniDiff.fail_attach`,
--- `MiniDiff.toggle_overlay`, `MiniDiff.get_buf_data`) and the documented source
--- specification (see |MiniDiff-source-specification|).
---
--- Mirrors the built-in Git source, but talks to the `arc` CLI:
--- - Reference text is the file from the arc index (`arc show :<path>`), or from
---   an explicit revision (`arc show <rev>:<path>`) set via `:MiniDiffArc`.
--- - Applying (staging) hunks is done with `arc add <file> -F <content>` (there is
---   no `arc apply`), by staging the "reference with selected hunks applied" text.
---
--- Requires Neovim >= 0.10 (uses `vim.system`) and the `arc` executable in PATH.
---
--- Usage: >lua
---   local diff = require('mini.diff')
---   local arc  = require('minidiff_arc')
---   -- Try Git first, fall back to arc (Arcadia repos have no `.git`)
---   diff.setup({ source = { diff.gen_source.git(), arc.gen_source() } })
---   arc.setup() -- registers `:MiniDiffArc {revision}`
--- <

local M = {}

-- Module state ---------------------------------------------------------------

-- Per-buffer cache: { revision, fs_event, timer, arc_dir, prefix, attached }
local arc_cache = {}

-- Revisions requested (via `set_revision`) before the arc source finished
-- attaching; applied once attach completes. Keyed by buffer id. Used when a file
-- is opened from the changed-files picker.
local pending_revision = {}

-- Sticky/global revision. `:MiniDiffArc <rev>` sets this; it becomes the default
-- reference for buffers attached later and is re-applied to all open arc buffers,
-- so a revision set once shows up in every file. `nil` means the arc index.
local global_revision = nil

local uv = vim.uv or vim.loop

-- `MiniDiff` public module. Requiring here is safe and idempotent.
local MiniDiff = require('mini.diff')

-- Helpers --------------------------------------------------------------------

local function notify(msg, level)
  vim.notify('(minidiff_arc) ' .. msg, level or vim.log.levels.WARN)
end

-- Run `arc <args>` asynchronously. `on_exit(code, stdout, stderr)` runs OUTSIDE
-- the main loop, so wrap any Neovim API usage in `vim.schedule`.
local function arc_run(args, cwd, on_exit)
  local cmd = vim.list_extend({ 'arc' }, args)
  vim.system(cmd, { cwd = cwd, text = true }, function(o)
    on_exit(o.code, o.stdout or '', o.stderr or '')
  end)
end

-- Resolve buffer's real on-disk path (following symlinks). Returns nil if none.
local function buf_realpath(buf_id)
  local name = vim.api.nvim_buf_get_name(buf_id)
  if name == '' then return nil end
  return uv.fs_realpath(name)
end

local function dirname(path) return vim.fn.fnamemodify(path, ':h') end
local function basename(path) return vim.fn.fnamemodify(path, ':t') end

-- Stop and close watcher/timer handles for a cache entry.
local function invalidate(cache)
  if cache == nil then return end
  if cache.fs_event ~= nil then
    pcall(uv.fs_event_stop, cache.fs_event)
    pcall(function() cache.fs_event:close() end)
  end
  if cache.timer ~= nil then
    pcall(function() cache.timer:stop() end)
    pcall(function() cache.timer:close() end)
  end
end

-- Reference text -------------------------------------------------------------

-- Fetch reference text for `buf_id` from arc and hand it to mini.diff.
-- Mirrors `H.git_set_ref_text` from the built-in Git source.
local function set_ref_text_impl(buf_id)
  local cache = arc_cache[buf_id]
  if cache == nil or not vim.api.nvim_buf_is_valid(buf_id) then return end

  -- Do not cache the path to react to possible buffer renames.
  local path = buf_realpath(buf_id)
  if path == nil then
    vim.schedule(function() pcall(MiniDiff.set_ref_text, buf_id, {}) end)
    return
  end

  -- `arc show [<rev>]:<path>` resolves <path> relative to the REPOSITORY ROOT
  -- (not the CWD), so build the repo-root-relative path from `--show-prefix`
  -- (which has no trailing slash and is empty at the repo root). No `./` form.
  local prefix = cache.prefix or ''
  local rel = prefix == '' and basename(path) or (prefix .. '/' .. basename(path))
  local pathspec = (cache.revision or '') .. ':' .. rel

  arc_run({ 'show', pathspec }, dirname(path), function(code, out)
    -- Any error unsets reference text (hides hunks): file not in index/revision,
    -- deleted, opened outside the work tree, etc.
    if code ~= 0 or out == '' then
      vim.schedule(function() pcall(MiniDiff.set_ref_text, buf_id, {}) end)
      return
    end
    local text = out:gsub('\r\n', '\n')
    vim.schedule(function() pcall(MiniDiff.set_ref_text, buf_id, text) end)
  end)
end

-- Watching -------------------------------------------------------------------

-- Watch the arc metadata dir and re-fetch reference on changes (external
-- `arc add`/`arc reset`, branch switches, etc.). Mirrors `H.git_setup_index_watch`.
-- NOTE: arc mounts via FUSE, so watchability of `arc_dir` should be confirmed on
-- a mounted repo. `M.setup()` also installs autocmd-based refresh as a fallback.
local function setup_watch(buf_id, arc_dir)
  local cache = arc_cache[buf_id]
  if cache == nil then return end
  invalidate(cache)

  local fs_event, timer = uv.new_fs_event(), uv.new_timer()
  cache.fs_event, cache.timer = fs_event, timer

  local on_change = function(err, _, _)
    if err then return end
    -- Debounce to avoid thrashing during incremental staging.
    timer:stop()
    timer:start(50, 0, vim.schedule_wrap(function() set_ref_text_impl(buf_id) end))
  end

  local ok = pcall(function() fs_event:start(arc_dir, { recursive = false }, on_change) end)
  if not ok then
    pcall(function() fs_event:close() end)
    cache.fs_event = nil
  end
end

-- Staging (apply hunks) ------------------------------------------------------

-- Build "reference with selected hunks applied" as an array of lines. The result
-- equals reference text where each hunk's reference region is replaced by the
-- corresponding buffer region. Mirrors the region math in `H.git_format_patch`.
local function build_staged_lines(ref_lines, buf_lines, hunks)
  hunks = vim.deepcopy(hunks)
  table.sort(hunks, function(a, b) return a.ref_start < b.ref_start end)

  local res, ref_idx = {}, 1
  for _, h in ipairs(hunks) do
    -- "add" hunks (ref_count == 0) insert AFTER `ref_start` (no reference line is
    -- consumed); "change"/"delete" replace the reference region
    -- [ref_start, ref_start + ref_count - 1].
    local copy_until = h.ref_count == 0 and h.ref_start or (h.ref_start - 1)
    for i = ref_idx, copy_until do
      res[#res + 1] = ref_lines[i]
    end
    for i = h.buf_start, h.buf_start + h.buf_count - 1 do
      res[#res + 1] = buf_lines[i]
    end
    ref_idx = h.ref_count == 0 and (h.ref_start + 1) or (h.ref_start + h.ref_count)
  end
  for i = ref_idx, #ref_lines do
    res[#res + 1] = ref_lines[i]
  end
  return res
end

-- Stage `hunks` into the arc index via `arc add <file> -F <tmp>`.
local function apply_hunks(buf_id, hunks)
  local cache = arc_cache[buf_id]
  if cache == nil then return end
  if cache.revision ~= nil then
    return notify('Staging is available only when diffing against the index (no revision set).')
  end

  local path = buf_realpath(buf_id)
  if path == nil then return end

  local data = MiniDiff.get_buf_data(buf_id)
  if data == nil or type(data.ref_text) ~= 'string' then return end

  local ref_lines = vim.split(data.ref_text, '\n')
  -- `ref_text` always ends with a trailing '\n', so drop the trailing empty item.
  if ref_lines[#ref_lines] == '' then ref_lines[#ref_lines] = nil end
  local buf_lines = vim.api.nvim_buf_get_lines(buf_id, 0, -1, false)

  local staged = build_staged_lines(ref_lines, buf_lines, hunks)
  local content = table.concat(staged, '\n') .. '\n'

  local tmp = vim.fn.tempname()
  local f = io.open(tmp, 'w')
  if f == nil then return notify('Could not create temporary file for staging.') end
  f:write(content)
  f:close()

  arc_run({ 'add', path, '-F', tmp }, dirname(path), function(code, _, stderr)
    pcall(os.remove, tmp)
    if code ~= 0 then
      vim.schedule(function() notify('`arc add` failed: ' .. (stderr or '')) end)
      return
    end
    -- Fallback in case the fs watcher does not catch the index change.
    vim.schedule(function() set_ref_text_impl(buf_id) end)
  end)
end

-- Source ---------------------------------------------------------------------

--- Generate an arc source for `mini.diff`
---
---@param opts table|nil Options. Possible fields:
---   - <revision> `(string|nil)` - initial revision to diff against. `nil` (default)
---     means the arc index (like the built-in Git source diffs against the index).
---
---@return table Source. See |MiniDiff-source-specification|.
M.gen_source = function(opts)
  opts = opts or {}
  -- Seed the sticky global revision from opts, if given.
  if opts.revision ~= nil then global_revision = opts.revision end

  local attach = function(buf_id)
    -- Attach to a buffer only once.
    if arc_cache[buf_id] ~= nil then return false end
    if buf_realpath(buf_id) == nil then return false end

    -- Claim the cache slot before the async repo check (so repeated attach
    -- attempts short-circuit). The real "is this in arc?" decision is async.
    -- New buffers inherit the current sticky global revision.
    arc_cache[buf_id] = { revision = global_revision }
    local cwd = dirname(buf_realpath(buf_id))

    -- `--arc-dir` (absolute) is the metadata dir to watch; `--show-prefix` is the
    -- repo->cwd path used to build repo-root-relative paths for `arc show`.
    -- `rev-parse` fails when not inside a mounted arc repo -> serves as detection.
    arc_run({ 'rev-parse', '--arc-dir', '--show-prefix' }, cwd, function(code, out)
      if code ~= 0 or out == '' then
        -- Not in an arc repo: let mini.diff try the next source.
        vim.schedule(function()
          pending_revision[buf_id] = nil
          if not vim.api.nvim_buf_is_valid(buf_id) then
            arc_cache[buf_id] = nil
            return
          end
          MiniDiff.fail_attach(buf_id)
        end)
        return
      end

      -- Output order matches the flag order: arc-dir first, prefix second
      -- (prefix has no trailing slash and is empty at the repo root).
      local lines = vim.split(out, '\n')
      local arc_dir = vim.trim(lines[1] or '')
      local prefix = vim.trim(lines[2] or '')
      if arc_dir ~= '' and not vim.startswith(arc_dir, '/') then
        arc_dir = vim.fs.normalize(vim.fs.joinpath(cwd, arc_dir))
      end

      vim.schedule(function()
        local cache = arc_cache[buf_id]
        if cache == nil or not vim.api.nvim_buf_is_valid(buf_id) then return end
        cache.arc_dir = arc_dir ~= '' and arc_dir or nil
        cache.prefix = prefix
        cache.attached = true
        if cache.arc_dir ~= nil then setup_watch(buf_id, cache.arc_dir) end

        -- Apply a revision requested before attach finished (e.g. a file opened
        -- from the changed-files picker), turning the overlay on for it.
        local pending = pending_revision[buf_id]
        pending_revision[buf_id] = nil
        if pending ~= nil then
          cache.revision = pending
          set_ref_text_impl(buf_id)
          local data = MiniDiff.get_buf_data(buf_id)
          if data ~= nil and not data.overlay then MiniDiff.toggle_overlay(buf_id) end
        else
          set_ref_text_impl(buf_id)
        end
      end)
    end)
  end

  local detach = function(buf_id)
    local cache = arc_cache[buf_id]
    arc_cache[buf_id] = nil
    pending_revision[buf_id] = nil
    invalidate(cache)
  end

  -- Clear cache on `:edit` (BufUnload) to force a fresh reattach, mirroring the
  -- Git source. `disable()` from `on_detach` is not always enough (a buffer not
  -- in an arc repo never fully attaches yet still populated `arc_cache`).
  local augroup = vim.api.nvim_create_augroup('MiniDiffSourceArc', { clear = true })
  vim.api.nvim_create_autocmd('BufUnload', {
    group = augroup,
    callback = function(ev)
      local cache = arc_cache[ev.buf]
      arc_cache[ev.buf] = nil
      pending_revision[ev.buf] = nil
      invalidate(cache)
    end,
    desc = 'Clear arc cache',
  })

  return { name = 'arc', attach = attach, detach = detach, apply_hunks = apply_hunks }
end

-- Revision command -----------------------------------------------------------

--- Set the arc revision used as reference (sticky/global)
---
--- Changes the reference text to each file's version from `revision` (empty/nil
--- goes back to the arc index). The revision is **sticky**: it is applied to every
--- currently attached arc buffer AND becomes the default for buffers opened later,
--- so you set it once and see hunks against it in every file. The overlay is turned
--- on for `buf_id` (the buffer the command was run from). Buffers still attaching
--- pick up the revision once attach completes.
---
---@param revision string|nil Revision (commit, branch, `trunk~3`, ...). Empty or
---   nil means the arc index.
---@param buf_id number|nil Buffer to turn the overlay on for. Default: 0 (current).
M.set_revision = function(revision, buf_id)
  buf_id = (buf_id == nil or buf_id == 0) and vim.api.nvim_get_current_buf() or buf_id
  local norm = (revision ~= nil and revision ~= '') and revision or nil

  -- Sticky/global: default for buffers opened later + re-applied to open ones.
  global_revision = norm

  for b, c in pairs(arc_cache) do
    if c.attached and vim.api.nvim_buf_is_valid(b) then
      c.revision = norm
      set_ref_text_impl(b)
    elseif not c.attached then
      -- Attach still in progress: defer; the attach callback will apply it.
      pending_revision[b] = norm
    end
  end

  -- Turn the overlay on for the buffer the command was run from.
  local cur = arc_cache[buf_id]
  if cur ~= nil and cur.attached then
    local data = MiniDiff.get_buf_data(buf_id)
    if data ~= nil and not data.overlay then MiniDiff.toggle_overlay(buf_id) end
  elseif cur == nil then
    notify('arc source is not attached to this buffer, but the revision is set globally.')
  end
end

-- Changed files / Telescope --------------------------------------------------

-- List files (repo-root-relative) changed between `revision` (nil/'' = index)
-- and the working tree. `on_result(files_or_nil, err)` runs OUTSIDE the main loop.
local function changed_files_async(revision, cwd, on_result)
  local args = { 'diff', '--name-only' }
  if revision ~= nil and revision ~= '' then args[#args + 1] = revision end
  arc_run(args, cwd, function(code, out, err)
    if code ~= 0 then return on_result(nil, err) end
    local files = {}
    for _, l in ipairs(vim.split(out, '\n')) do
      l = vim.trim(l)
      if l ~= '' then files[#files + 1] = l end
    end
    on_result(files, nil)
  end)
end

--- Get files changed between an arc revision and the working tree
---
--- Asynchronous. Repo-root-relative paths plus the absolute repo root are passed
--- to the callback (scheduled on the main loop).
---
---@param revision string|nil Revision to compare against. `nil`/empty = arc index.
---@param buf_id number|nil Buffer used to locate the repo. Default: current buffer.
---@param on_result function Called as `on_result(files, toplevel, err)`.
M.changed_files = function(revision, buf_id, on_result)
  buf_id = (buf_id == nil or buf_id == 0) and vim.api.nvim_get_current_buf() or buf_id
  local path = buf_realpath(buf_id)
  local cwd = path ~= nil and dirname(path) or uv.cwd()

  arc_run({ 'rev-parse', '--show-toplevel' }, cwd, function(code, top_out)
    local top = vim.trim(top_out)
    local toplevel = (code == 0 and top ~= '') and top or cwd
    changed_files_async(revision, cwd, function(files, err)
      vim.schedule(function() on_result(files, toplevel, err) end)
    end)
  end)
end

-- Open `path` and, if `revision` is set, show that revision's diff/overlay in it.
local function open_with_revision(path, revision)
  vim.cmd('edit ' .. vim.fn.fnameescape(path))
  if revision == nil or revision == '' then return end
  local buf = vim.api.nvim_get_current_buf()
  local cache = arc_cache[buf]
  if cache ~= nil and cache.attached then
    M.set_revision(revision, buf)
  else
    -- Not attached yet: record pending and make sure attach runs.
    pending_revision[buf] = revision
    if MiniDiff.get_buf_data(buf) == nil then pcall(MiniDiff.enable, buf) end
  end
end

--- Telescope picker of files changed vs the buffer's arc revision
---
--- Uses the revision currently set for the buffer (via `:MiniDiffArc`), or the
--- arc index if none. Selecting a file opens it with the same revision diff shown.
--- Requires 'nvim-telescope/telescope.nvim'.
---
---@param opts table|nil Telescope options. May also contain `revision` to override
---   the compared revision.
M.pick_changed_files = function(opts)
  opts = opts or {}
  local has_telescope, pickers = pcall(require, 'telescope.pickers')
  if not has_telescope then return notify('telescope.nvim is not available.') end
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  local buf_id = vim.api.nvim_get_current_buf()
  local revision = opts.revision
  if revision == nil then
    local cache = arc_cache[buf_id]
    revision = cache ~= nil and cache.revision or nil
  end

  M.changed_files(revision, buf_id, function(files, toplevel, err)
    if files == nil then return notify('`arc diff` failed: ' .. (err or '')) end
    if #files == 0 then return notify('No changed files vs ' .. (revision or 'index') .. '.') end

    pickers.new(opts, {
      prompt_title = 'Changed vs ' .. (revision or 'index'),
      finder = finders.new_table({
        results = files,
        entry_maker = function(rel)
          local full = vim.fs.normalize(vim.fs.joinpath(toplevel, rel))
          return { value = full, display = rel, ordinal = rel, path = full }
        end,
      }),
      sorter = conf.generic_sorter(opts),
      previewer = conf.file_previewer(opts),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local entry = action_state.get_selected_entry()
          if entry ~= nil then open_with_revision(entry.path, revision) end
        end)
        return true
      end,
    }):find()
  end)
end

--- Set up the command and optional autocmd-based refresh fallback
---
---@param opts table|nil Options. Possible fields:
---   - <refresh_events> `(table|false)` - autocmd events to re-fetch reference on
---     (fallback for FUSE fs-watch). Default: `{ 'BufWritePost', 'FocusGained',
---     'ShellCmdPost' }`. Set to `false` to disable.
M.setup = function(opts)
  opts = opts or {}

  if vim.fn.executable('arc') ~= 1 then notify('`arc` executable not found in PATH.') end

  vim.api.nvim_create_user_command('MiniDiffArc', function(args)
    M.set_revision(args.args, 0)
  end, { nargs = '?', desc = 'mini.diff: diff current file against an arc revision' })

  vim.api.nvim_create_user_command('MiniDiffArcFiles', function()
    M.pick_changed_files()
  end, { desc = 'mini.diff: Telescope files changed vs current arc revision' })

  local events = opts.refresh_events
  if events == nil then events = { 'BufWritePost', 'FocusGained', 'ShellCmdPost' } end
  if events ~= false then
    local augroup = vim.api.nvim_create_augroup('MiniDiffSourceArcRefresh', { clear = true })
    vim.api.nvim_create_autocmd(events, {
      group = augroup,
      callback = function()
        local buf_id = vim.api.nvim_get_current_buf()
        if arc_cache[buf_id] ~= nil then set_ref_text_impl(buf_id) end
      end,
      desc = 'Refresh arc reference text',
    })
  end
end

return M
