-- vim:foldmethod=marker:
local vars = require 'vars'
local cwd = vars.cwd

local rtp = vim.api.nvim_get_option 'packpath'
rtp = rtp .. ',' .. cwd
vim.api.nvim_set_option('packpath', rtp)

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
    -- use 'github/copilot.vim'
    use 'udalov/kotlin-vim'
    use 'wlangstroth/vim-racket'
    use 'ziglang/zig.vim'
    use 'fatih/vim-go'
    use {
        'voldikss/vim-floaterm',
        config = function()
            -- vim.g.floaterm_wintype = 'split'
            vim.g.floaterm_width = 0.8
            vim.g.floaterm_position = 'bottom'
        end,
    }

    use {
        'ThePrimeagen/harpoon',
    }
    -- use 'weirongxu/plantuml-previewer.vim'
    -- use 'tyru/open-browser.vim'
    use 'tikhomirov/vim-glsl'

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
        end,
        -- }}}
    }

    use 'editorconfig/editorconfig-vim'

    use 'NLKNguyen/papercolor-theme'
    use { 'sonph/onehalf', rtp = 'vim/' }
    use 'cocopon/iceberg.vim'
    use 'sainnhe/edge'

    use 'scrooloose/nerdtree'
    use {
        'kyazdani42/nvim-tree.lua',
        -- {{{ config
        config = function()
            require('nvim-tree').setup {
                update_focused_file = {
                    update_root = true,
                },
                filters = {
                    dotfiles = false,
                },
                view = {
                    mappings = {
                        list = {
                            { key = 't', action = 'tabnew' },
                            { key = 's', action = 'vsplit' },
                            { key = 'i', action = 'split' },
                        },
                    },
                },
            }
        end,
        -- }}}
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
                cpp = { 'clangtidy' },
            }

            vim.cmd "au BufWritePost <buffer> lua require('lint').try_lint()"
        end,
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
        -- {{{ config
        config = function()
            local cmp = require 'cmp'
            cmp.setup {
                snippet = {
                    expand = function(args)
                        require('luasnip').lsp_expand(args.body)
                    end,
                },

                sources = {
                    { name = 'nvim-lsp' },
                    { name = 'luasnip' },
                    { name = 'buffer' },
                    { name = 'cmp_tabnine' },
                },
                mapping = {
                    ['<C-p>'] = cmp.mapping.select_prev_item(),
                    ['<C-n>'] = cmp.mapping.select_next_item(),
                },
            }
        end,
        -- }}}
    }
    -- use { 'tzachar/cmp-tabnine', run = './install.sh', requires = 'hrsh7th/nvim-cmp' }

    use 'honza/vim-snippets'

    use {
        'mhartington/formatter.nvim',
        -- {{{ config
        config = function()
            require('formatter').setup {
                filetype = {
                    lua = {
                        function()
                            local util = require 'packer.util'
                            local cwd = require('vars').cwd
                            return {
                                exe = 'stylua',
                                args = {
                                    '--config-path ' .. util.join_paths(cwd, 'lua', 'stylua.toml'),
                                    '-',
                                },
                                stdin = true,
                            }
                        end,
                    },
                    json = {
                        function()
                            return {
                                exe = 'prettier',
                                args = {
                                    '--parser',
                                    'json',
                                },
                                stdin = true,
                            }
                        end,
                    },
                    javascript = {
                        function()
                            return {
                                exe = 'prettier',
                                args = {
                                    '--parser',
                                    'babel',
                                },
                                stdin = true,
                            }
                        end,
                    },
                    typescript = {
                        function()
                            return {
                                exe = 'prettier',
                                args = {
                                    '--parser',
                                    'typescript',
                                },
                                stdin = true,
                            }
                        end,
                    },
                    typescriptreact = {
                        function()
                            return {
                                exe = 'prettier',
                                args = {
                                    '--parser',
                                    'typescript',
                                },
                                stdin = true,
                            }
                        end,
                    },
                    python = {
                        function()
                            return {
                                exe = 'black',
                                args = { '-' },
                                stdin = true,
                            }
                        end,
                    },
                    rust = {
                        function()
                            return {
                                exe = 'rustfmt',
                                args = { '--emit=stdout', '--edition=2021' },
                                stdin = true,
                            }
                        end,
                    },
                    cpp = {
                        require('formatter.filetypes.cpp').clangformat,
                    },
                    glsl = {
                        require('formatter.defaults').clangformat,
                    },
                },
            }
        end,
        -- }}}
    }

    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'saadparwaiz1/cmp_luasnip'

    use {
        'neovim/nvim-lspconfig',
        -- {{{ config
        config = function()
            local nvim_lsp = require 'lspconfig'

            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

            local opts = { noremap = true, silent = true }
            vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
            vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
            vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
            vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

            local on_attach = function(client, bufnr)
                vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

                vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
                -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
                vim.api.nvim_buf_set_keymap(
                    bufnr,
                    'n',
                    '<space>wa',
                    '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>',
                    opts
                )
                vim.api.nvim_buf_set_keymap(
                    bufnr,
                    'n',
                    '<space>wr',
                    '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>',
                    opts
                )
                vim.api.nvim_buf_set_keymap(
                    bufnr,
                    'n',
                    '<space>wl',
                    '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>',
                    opts
                )
                vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
            end

            nvim_lsp.tsserver.setup {
                capabilities = capabilities,
                root_dir = function()
                    return vim.fn.getcwd()
                end,
                on_attach = on_attach,
            }
            nvim_lsp.pyright.setup {
                capabilities = capabilities,
                root_dir = function()
                    return vim.fn.getcwd()
                end,
                on_attach = on_attach,
            }
            nvim_lsp.gopls.setup {
                capabilities = capabilities,
            }
            nvim_lsp.clangd.setup {
                capabilities = capabilities,
                on_attach = on_attach,
            }
        end,
        -- }}}
    }
end)

prequire 'packer_compiled'

vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]]
