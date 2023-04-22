-- vim:foldmethod=marker:
local vars = require 'vars'
local cwd = vars.cwd

local util = require 'packer.util'
local packer = require 'packer'

packer.init {
    package_root = util.join_paths(cwd, 'pack'),
    compile_path = util.join_paths(cwd, 'lua', 'packer_compiled.lua'),
}

local function prequire(...)
    local status, lib = pcall(require, ...)
    if status then
        return lib
    end
    return nil
end

packer.startup(function()
    use { 'udalov/kotlin-vim', ft = 'kotlin' }
    use { 'wlangstroth/vim-racket', ft = 'racket' }
    use { 'ziglang/zig.vim', ft = 'zig' }
    use { 'tikhomirov/vim-glsl', ft = 'glsl' }
    use { 'fatih/vim-go', ft = 'go' }
    use { 'hashivim/vim-terraform', ft = 'terraform' }

    use { 'mhinz/vim-startify' }

    use {
        'voldikss/vim-floaterm',
        config = function()
            vim.g.floaterm_width = 0.8
            vim.g.floaterm_position = 'bottom'
        end,
    }

    use {
        'ThePrimeagen/harpoon',
        config = function()
            require('harpoon').setup {
                global_settings = {
                    enter_on_sendcmd = true,
                },
            }
        end,
    }

    use {
        'nvim-treesitter/nvim-treesitter',
        -- {{{ config
        config = function()
            require('nvim-treesitter.configs').setup {
                ensure_installed = { 'http', 'json', 'org' },

                sync_install = false,

                ignore_install = { 'javascript' },

                highlight = {
                    enable = true,

                    disable = { 'c', 'rust' },

                    additional_vim_regex_highlighting = false,
                },
            }
        end,
        -- }}}
    }

    use {
        'NTBBloodbath/rest.nvim',
        -- {{{ config
        config = function()
            require('rest-nvim').setup {
                result_split_horizontal = false,
                skip_ssl_verification = false,
                highlight = {
                    enabled = true,
                    timeout = 150,
                },
                jump_to_request = false,
                env_file = '.env',
                yank_dry_run = true,
            }

            vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
                pattern = { '*.http' },
                callback = function()
                    vim.api.nvim_set_keymap('n', '<C-n>', '<Plug>RestNvim', { noremap = true })
                end,
            })
        end,
        -- }}}
    }

    use 'editorconfig/editorconfig-vim'

    use 'NLKNguyen/papercolor-theme'
    use { 'sonph/onehalf', rtp = 'vim/' }
    use 'cocopon/iceberg.vim'
    use {
        'sainnhe/edge',
        config = function()
            if vim.env['DARK_MODE'] then
                vim.g.edge_transparent_background = 2
            end
        end,
    }

    use {
        'kyazdani42/nvim-tree.lua',
        config = require 'plugins.nvim-tree',
    }

    use 'tpope/vim-surround'
    use 'tpope/vim-commentary'
    use 'tpope/vim-fugitive'

    use 'godlygeek/tabular'

    use {
        'mfussenegger/nvim-lint',
        config = function()
            require('lint').linters_by_ft = {
                python = { 'flake8' },
                -- cpp = { 'clangtidy' },
            }

            vim.cmd "au BufWritePost <buffer> lua require('lint').try_lint()"
        end,
    }
    use {
        'sakhnik/nvim-gdb',
    }

    use 'terryma/vim-multiple-cursors'
    use {
        'Raimondi/delimitMate',
        config = function()
            vim.g.delimitMate_expand_cr = 1
            vim.g.delimitMate_expand_space = 1
            vim.g.delimitMate_matchpairs = '(:),[:],{:}'
        end,
    }

    use 'francoiscabrol/ranger.vim'
    use 'rbgrouleff/bclose.vim'

    use {
        'famiu/feline.nvim',
        config = function()
            require('feline').setup()
        end,
    }

    use {
        'nvim-telescope/telescope.nvim',
        -- {{{ config
        config = function()
            local actions = require 'telescope.actions'

            require('telescope').setup {
                defaults = {
                    mappings = {
                        i = {
                            ['<ESC>'] = actions.close,
                        },
                    },
                },
            }
        end,
        -- }}}
    }
    use 'nvim-lua/popup.nvim'
    use 'nvim-lua/plenary.nvim'

    use 'L3MON4D3/LuaSnip'
    use {
        'hrsh7th/nvim-cmp',
        requires = { { 'L3MON4D3/LuaSnip' } },
        config = function()
            require 'plugins.cmp'
        end,
    }

    use 'honza/vim-snippets'

    use {
        'mhartington/formatter.nvim',
        config = function()
            require 'plugins.formatter'
        end,
    }

    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'saadparwaiz1/cmp_luasnip'

    use {
        'neovim/nvim-lspconfig',
        config = function()
            require 'plugins.lspconfig'
        end,
    }
end)

prequire 'packer_compiled'

vim.api.nvim_create_autocmd('BufWritePost', {
    pattern = 'plugins.lua',
    command = 'source <afile> | PackerCompile',
    group = vim.api.nvim_create_augroup('packer_user_config', { clear = true }),
})
