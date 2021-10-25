local cwd = vim.fn.getcwd()
local rtp =  vim.api.nvim_get_option('packpath')
rtp = rtp .. "," .. cwd
vim.api.nvim_set_option('packpath', rtp)


local packer = require 'packer' 


local util = require 'packer.util'

packer.init({
	package_root = util.join_paths(cwd, 'pack'),
	compile_path = util.join_paths(cwd, 'packer_compiled.lua'),
})

local function prequire(...)
	local status, lib = pcall(require, ...)
	if (status) then return lib end
	return nil
end

packer.startup(function()
	use 'wbthomason/packer.nvim'

	use 'scrooloose/nerdtree'
	use 'NLKNguyen/papercolor-theme'
	use { 
		'sonph/onehalf', 
		rtp = 'vim/'
	}

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
		'nvim-telescope/telescope.nvim',
		config = function()
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
	}
	use 'nvim-lua/popup.nvim'
	use 'nvim-lua/plenary.nvim'

	use 'L3MON4D3/LuaSnip'
	use { 
		'hrsh7th/nvim-cmp',
		config = function()
			require'cmp'.setup {
				snippet = {
					expand = function(args)
						require'luasnip'.lsp_expand(args.body)
					end
				},

				sources = {
					{ name = 'luasnip' },
				},
			}
		end
	}
	use { 'saadparwaiz1/cmp_luasnip' }

end)

prequire('packer_compiled')
