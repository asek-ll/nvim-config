local work_dir = vim.fn.expand '<sfile>:p:h'
vim.opt.rtp:append(work_dir)

require 'options'
require 'keys'
require 'plugins'
require 'snippets'

if vim.g.neovide then
    require 'neovide'
end

-- vim.cmd('silent! colorscheme PaperColor')
-- vim.cmd('silent! colorscheme onehalflight')
vim.cmd 'silent! colorscheme edge'

if vim.env['DARK_MODE'] or vim.g.neovide then
    vim.api.nvim_set_option('background', 'dark')
else
    vim.api.nvim_set_option('background', 'light')
end
