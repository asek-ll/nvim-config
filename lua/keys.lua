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
map('n', '<Leader>1', '<cmd>NvimTreeFindFileToggle<CR>')
map('n', '<F2>', '<cmd>FloatermNew lf<CR>')

map('n', '<F3>', '<cmd>Telescope find_files<CR>')
map('n', '<F4>', '<cmd>lua require("telescope-lists").buffers()<CR>')
map('n', '<F5>', '<cmd>Telescope live_grep<CR>')
map('n', '<C-A-s>', '<cmd>Telescope find_files cwd=' .. cwd .. '<CR>')
map('n', '<Leader>.', '<cmd>Telescope find_files cwd=' .. cwd .. '<CR>')
map('n', '<Leader>5', '<cmd>Telescope resume<CR>')

map('t', '<F7>', '<cmd>FloatermToggle<CR>')
map('n', '<F7>', '<cmd>FloatermToggle<CR>')


map('n', '<F9>', ':make!<CR>')

map('n', '<A-2>', '<cmd>Ranger<CR>')
map('t', '<Esc>', '<C-\\><C-n>')
map('n', '<C-k>', '<cmd>Commentary<CR>')
map('v', '<C-k>', ":'<,'>Commentary<CR>")
map('n', '<C-f>', '<cmd>Format<CR>')

map('n', '<Leader>df', '<cmd>lua vim.diagnostic.goto_next()<CR>')
map('n', '<Leader>3', '<cmd>Telescope diagnostics<CR>')
