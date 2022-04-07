local function map(mode, lhs, rhs, opts)
    local options = { noremap = true }
    if opts then
        options = vim.tbl_extend('force', options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- vim.g.mapleader = ' '

map('n', '<F1>', ':NERDTreeToggle<CR>')
map('n', '<A-1>', ':NERDTreeFind<CR>')
map('n', '<F2>', ':Telescope file_browser<CR>')
map('n', '<F3>', ':Telescope find_files<CR>')
map('n', '<F4>', ':Telescope buffers<CR>')
map('n', '<F5>', ':Telescope live_grep<CR>')

map('n', '<F7>', ':new term://zsh<CR><C-w>Ji')
map('n', '<F9>', ':make!<CR>')
map('n', '<A-2>', ':Ranger<CR>')
map('t', '<Esc>', '<C-\\><C-n>')
map('n', '<C-k>', ':Commentary<CR>')
map('v', '<C-k>', ':Commentary<CR>')
map('n', '<C-f>', ':Format<CR>')

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
