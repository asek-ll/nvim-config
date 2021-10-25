local cwd = vim.fn.expand('<sfile>:p:h')

local global_options = {
	backupdir = cwd .. "/.backupdir",
	directory = cwd .. "/.swapdir",
	undodir = cwd .. "/.undodir",
	backspace = 'indent,eol,start',
	history = 50,
	ruler =  true,
	showcmd =  true,
	incsearch =  true,
	clipboard =  'unnamedplus',
	wildmenu =  true,
	listchars =  "eol:¬,trail:~,nbsp:%,tab:▏ ",
	foldlevelstart =  3,
	smarttab =  true,
	autoread =  true,
	ignorecase = true,
	termguicolors = true,
	completeopt = "menu,menuone,noselect",
	mouse = "nv",
}

local window_options = {
	colorcolumn = "120",
	list = true,
	number = true,
	relativenumber = true,
	cursorline = true,
}

local buffer_options = {
	iminsert = 0,
	imsearch = 0,
	shiftwidth =  4,
	tabstop = 4,
	expandtab = false,
	autoindent = true,
	undofile = true,
}

for k, v in pairs(global_options) do
	vim.api.nvim_set_option(k,v)
end

for k, v in pairs(window_options) do
	vim.api.nvim_win_set_option(0, k,v)
	vim.api.nvim_set_option(k,v)
end

for k, v in pairs(buffer_options) do
	vim.api.nvim_buf_set_option(0, k,v)
	vim.api.nvim_set_option(k,v)
end
