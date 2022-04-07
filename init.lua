require('options')
require('plugins')
require('keys')
require('snippets')

-- vim.cmd('silent! colorscheme PaperColor')
-- vim.cmd('silent! colorscheme onehalflight')
vim.cmd('silent! colorscheme edge')

if vim.env['DARK_MODE'] then
	vim.api.nvim_set_option('background', 'dark')
	vim.cmd('hi Normal guibg=NONE ctermbg=NONE')
	vim.cmd('hi EndOfBuffer guibg=NONE ctermbg=NONE')
else
	vim.api.nvim_set_option('background', 'light')
end--
