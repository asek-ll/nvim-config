local packer = require 'packer' 


local telescope_setup = function()
	local actions = require("telescope.actions")

	require("telescope").setup({
		defaults = {
			mappings = {
				i = {
					["<ESC>"] = actions.close,
				},
			},
		},
	})
end

packer.startup(function()
	use 'wbthomason/packer.nvim'

	use 'scrooloose/nerdtree'
	use 'NLKNguyen/papercolor-theme'

	use 'tpope/vim-surround'
	use 'tpope/vim-commentary'

	use 'terryma/vim-multiple-cursors'
	use 'Raimondi/delimitMate'

	use 'francoiscabrol/ranger.vim'
	use 'rbgrouleff/bclose.vim'

	use {
		'famiu/feline.nvim',
		config = function() require'feline'.setup() end
	}

	use { 
		'nvim-telescope/telescope.nvim'
	}
	use 'nvim-lua/popup.nvim'
	use 'nvim-lua/plenary.nvim'

	use { 'L3MON4D3/LuaSnip' } 
	use { 
		'hrsh7th/nvim-cmp',
		config = function ()
			require'cmp'.setup {
				snippet = {
					expand = function(args)
						require'luasnip'.lsp_expand(args.body)
					end
				},

				sources = {
					{ name = 'luasnip' },
					-- more sources
				},
			}
		end
	}
	use { 'saadparwaiz1/cmp_luasnip' }

end)


local function map(mode, lhs, rhs, opts)
	local options = {noremap = true}
	if opts then options = vim.tbl_extend('force', options, opts) end
	vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- vim.api.nvim_set_var('mapleader', ' ')  

map('n', '<F1>', ":NERDTreeToggle<CR>") 
map('n', '<A-1>', ":NERDTreeFind<CR>") 
telescope_setup()
map('n', '<F2>', ":Telescope file_browser<CR>") 
map('n', '<F3>', ":Telescope find_files<CR>") 
map('n', '<F4>', ":Telescope buffers<CR>") 
map('n', '<F5>', ":Telescope live_grep<CR>") 

map('n', '<F7>', ":new term://zsh<CR><C-w>Ji") 
map('n', '<A-2>', ":Ranger<CR>") 
map('t', '<Esc>', "<C-\\><C-n>") 
map('n', '<C-k>', ":Commentary<CR>") 
map('v', '<C-k>', ":Commentary<CR>") 


vim.api.nvim_set_var('nvim_tree_show_icons', {
	folders = 1, 
	folder_arrows = 1,
})

vim.cmd("silent! colorscheme PaperColor")

local global_options = {
	background = 'light',
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
	autoindent = true
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

local luasnip = require('luasnip')

local t = function(str)
	return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
	local col = vim.fn.col('.') - 1
	if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
		return true
	else
		return false
	end
end

local cmp = require'cmp'

_G.tab_complete = function()
	print("tab_complte")
	if vim.fn.pumvisible() == 1 then
		return t "<C-n>"
	elseif luasnip and luasnip.expand_or_jumpable() then
		return t("<Plug>luasnip-expand-or-jump")
	elseif check_back_space() then
		return t "<Tab>"
	elseif cmp.visible() then
		return ""
	end
	return t "<Tab>"
end
_G.s_tab_complete = function()
	if vim.fn.pumvisible() == 1 then
		return t "<C-p>"
	elseif luasnip and luasnip.jumpable(-1) then
		return t("<Plug>luasnip-jump-prev")
	else
		return t "<S-Tab>"
	end
	return ""
end

cmp.setup({
	sources = {
		{ name = 'luasnip' },
	}
})

require('snippets')

vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
-- vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
-- vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
vim.api.nvim_set_keymap("i", "<C-E>", "<Plug>luasnip-next-choice", {})
vim.api.nvim_set_keymap("s", "<C-E>", "<Plug>luasnip-next-choice", {})
