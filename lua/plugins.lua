local options = require 'options'
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

local non_yandex_plugins = {
    { 'fatih/vim-go', ft = { 'go', 'gohtmltmpl' } },
}

local yandex_plugins = {
    { 'saltstack/salt-vim', ft = 'sls' },
    { 'google/vim-jsonnet', ft = 'jsonnet' },
    {
        'coder/claudecode.nvim',
        opts = { terminal_cmd = '/Users/denblo/bin/cc' },
        config = true,
    },
}

local common_plugins = {
    { 'udalov/kotlin-vim', ft = 'kotlin' },
    { 'wlangstroth/vim-racket', ft = 'racket' },
    { 'ziglang/zig.vim', ft = 'zig' },
    { 'tikhomirov/vim-glsl', ft = 'glsl' },
    { 'hashivim/vim-terraform', ft = 'terraform' },
    { 'LnL7/vim-nix', ft = 'nix' },
    {
        'LhKipp/nvim-nu',
        config = function()
            require('nu').setup {
                use_lsp_features = false,
            }
        end,
        ft = 'nu',
    },
    {
        'voldikss/vim-floaterm',
        config = function()
            vim.g.floaterm_width = 0.8
            vim.g.floaterm_position = 'bottom'
        end,
    },
    {
        'nvim-treesitter/nvim-treesitter',
        -- {{{ config
        build = ':TSUpdate',
        config = function()
            vim.filetype.add { extension = { templ = 'templ' } }
            require('nvim-treesitter').setup {
                ensure_installed = { 'json', 'org', 'templ' },

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
            local linters_by_ft = {
                python = { 'ruff' },
                yaml = { 'yamllint' },
            }

            if not options.is_yandex() then
                linters_by_ft.go = { 'golangcilint' }
            end

            require('lint').linters_by_ft = linters_by_ft

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
                            ['<Ctrl+l>'] = actions.send_selected_to_loclist,
                            ['<Ctrl+q>'] = actions.send_selected_to_qflist,
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
local plugins = {}
for _, plugin in pairs(common_plugins) do
    table.insert(plugins, plugin)
end
if options.is_yandex() then
    for _, plugin in pairs(yandex_plugins) do
        table.insert(plugins, plugin)
    end
else
    for _, plugin in pairs(non_yandex_plugins) do
        table.insert(plugins, plugin)
    end
end

require('lazy').setup(plugins)
