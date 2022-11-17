local vars = require 'vars'
local cwd = vars.cwd

local function map(mode, lhs, rhs, opts)
    local options = { noremap = true }
    if opts then
        options = vim.tbl_extend('force', options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end


vim.g.mapleader = ' '

map('n', '<F1>', '<cmd>NvimTreeToggle<CR>')
map('n', '<A-1>', '<cmd>NvimTreeFindFileToggle<CR>')
map('n', '<F2>', '<cmd>lua require("harpoon.ui").toggle_quick_menu()<CR>')

map('n', '<F3>', '<cmd>Telescope find_files<CR>')
map('n', '<F4>', '<cmd>lua require("telescope-lists").buffers()<CR>')
map('n', '<F5>', '<cmd>Telescope live_grep<CR>')
map('n', '<C-A-s>', '<cmd>Telescope find_files cwd=' .. cwd .. '<CR>')

-- map('t', '<F7>', '<C-\\><C-n>:FloatermToggle<CR>')
map('t', '<F7>', '<cmd>FloatermToggle<CR>')

-- map('n', '<F7>', ':FloatermToggle<CR>')
map('n', '<F7>', '<cmd>lua require("harpoon.tmux").gotoTerminal(1)<CR>')
map('n', '<Leader>7', '<cmd>lua require("harpoon.cmd-ui").toggle_quick_menu()<CR>')

-- map('n', '<F9>', ':lua require("harpoon.tmux").sendCommand(1, 1)<CR>')
map('n', '<F9>', '<cmd>lua require("harpoon.tmux").sendCommand(1, 1)require("harpoon.tmux").gotoTerminal(1)<CR>')


-- map('n', '<F9>', ':make!<CR>')
map('n', '<A-2>', '<cmd>Ranger<CR>')
map('t', '<Esc>', '<C-\\><C-n>')
map('n', '<C-k>', '<cmd>Commentary<CR>')
map('v', '<C-k>', ':\'<,\'>Commentary<CR>')
map('n', '<C-f>', '<cmd>Format<CR>')

local cmp = require 'cmp'

local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
    local col = vim.fn.col '.' - 1
    if col == 0 or vim.fn.getline('.'):sub(col, col):match '%s' then
        return true
    else
        return false
    end
end

local luasnip = require 'luasnip'

_G.tab_complete = function()
    print 'tab_complte'
    if vim.fn.pumvisible() == 1 then
        return t '<C-n>'
    elseif luasnip and luasnip.expand_or_jumpable() then
        return t '<Plug>luasnip-expand-or-jump'
    elseif check_back_space() then
        return t '<Tab>'
    elseif cmp.visible() then
        return ''
    end
    return t '<Tab>'
end
_G.s_tab_complete = function()
    if vim.fn.pumvisible() == 1 then
        return t '<C-p>'
    elseif luasnip and luasnip.jumpable(-1) then
        return t '<Plug>luasnip-jump-prev'
    else
        return t '<S-Tab>'
    end
    return ''
end

vim.api.nvim_set_keymap('i', '<Tab>', 'v:lua.tab_complete()', { expr = true })
vim.api.nvim_set_keymap('s', '<Tab>', 'v:lua.tab_complete()', { expr = true })
-- vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
-- vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
vim.api.nvim_set_keymap('i', '<C-E>', '<Plug>luasnip-next-choice', {})
vim.api.nvim_set_keymap('s', '<C-E>', '<Plug>luasnip-next-choice', {})
