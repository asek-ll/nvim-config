local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system {
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable',
        lazypath,
    }
end
vim.opt.rtp:prepend(lazypath)
require('lazy').setup {
    { 'udalov/kotlin-vim', ft = 'kotlin' },
    { 'wlangstroth/vim-racket', ft = 'racket' },
    { 'ziglang/zig.vim', ft = 'zig' },
    { 'tikhomirov/vim-glsl', ft = 'glsl' },
    { 'fatih/vim-go', ft = 'go' },
    { 'hashivim/vim-terraform', ft = 'terraform' },

    -- { 'mhinz/vim-startify' },
    {
        'voldikss/vim-floaterm',
        config = function()
            vim.g.floaterm_width = 0.8
            vim.g.floaterm_position = 'bottom'
        end,
    },
    {
        'ThePrimeagen/harpoon',
        config = function()
            require('harpoon').setup {
                global_settings = {
                    enter_on_sendcmd = true,
                },
            }
        end,
    },
    {
        'nvim-treesitter/nvim-treesitter',
        -- {{{ config
        config = function()
            require('nvim-treesitter.configs').setup {
                ensure_installed = { 'json', 'org' },

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
    },
    {
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
    },

    'NLKNguyen/papercolor-theme',
    {
        'sonph/onehalf',
        config = function(plugin)
            vim.opt.rtp:append(plugin.dir .. '/vim')
        end,
    },
    'cocopon/iceberg.vim',
    {
        'sainnhe/edge',
        config = function()
            if vim.env['DARK_MODE'] then
                vim.g.edge_transparent_background = 2
            end
        end,
    },

    {
        'kyazdani42/nvim-tree.lua',
        config = require 'plugins.nvim-tree',
    },

    'tpope/vim-surround',
    'tpope/vim-commentary',
    'tpope/vim-fugitive',

    'godlygeek/tabular',

    {
        'mfussenegger/nvim-lint',
        config = function()
            require('lint').linters_by_ft = {
                python = { 'flake8' },
                -- cpp = { 'clangtidy' },
            }

            vim.cmd "au BufWritePost <buffer> lua require('lint').try_lint()"
        end,
    },
    {
        'sakhnik/nvim-gdb',
    },

    'terryma/vim-multiple-cursors',
    {
        'Raimondi/delimitMate',
        config = function()
            vim.g.delimitMate_expand_cr = 1
            vim.g.delimitMate_expand_space = 1
            vim.g.delimitMate_matchpairs = '(:),[:],{:}'
        end,
    },

    'francoiscabrol/ranger.vim',
    'rbgrouleff/bclose.vim',

    {
        'famiu/feline.nvim',
        config = function()
            require('feline').setup()
        end,
    },

    {
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
    },
    'nvim-lua/popup.nvim',
    'nvim-lua/plenary.nvim',

    'L3MON4D3/LuaSnip',
    {
        'hrsh7th/nvim-cmp',
        dependencies = { 'L3MON4D3/LuaSnip' },
        config = function()
            require 'plugins.cmp'
        end,
    },

    'honza/vim-snippets',

    {
        'mhartington/formatter.nvim',
        config = function()
            require 'plugins.formatter'
        end,
    },

    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-nvim-lsp',
    'saadparwaiz1/cmp_luasnip',

    {
        'neovim/nvim-lspconfig',
        config = function()
            require 'plugins.lspconfig'
        end,
    },
}
