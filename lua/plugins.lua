local cwd = vim.fn.expand('<sfile>:p:h')

local rtp =  vim.api.nvim_get_option('packpath')
rtp = rtp .. "," .. cwd
vim.api.nvim_set_option('packpath', rtp)

local util = require 'packer.util'
local packer = require 'packer' 

packer.init({
    package_root = util.join_paths(cwd, 'pack'),
    compile_path = util.join_paths(cwd, 'lua', 'packer_compiled.lua'),
})

local function prequire(...)
    local status, lib = pcall(require, ...)
    if (status) then return lib end
    return nil
end

packer.startup(function()
    use 'udalov/kotlin-vim'

    use 'wlangstroth/vim-racket'

    use {
        'nvim-treesitter/nvim-treesitter',
        config = function() 
            require'nvim-treesitter.configs'.setup {
                ensure_installed = { 'http', 'json' },

                sync_install = false,

                ignore_install = { "javascript" },

                highlight = {
                    enable = true,

                    disable = { "c", "rust" },

                    additional_vim_regex_highlighting = false,
                },
            }
        end
    }

    use 'ziglang/zig.vim'

    use {
        'NTBBloodbath/rest.nvim',
        config = function() 
            require("rest-nvim").setup({
                result_split_horizontal = false,
                skip_ssl_verification = false,
                highlight = {
                    enabled = true,
                    timeout = 150,
                },
                jump_to_request = false,
                env_file = '.env',
                yank_dry_run = true,
            })
        end
    }

    use 'editorconfig/editorconfig-vim'

    use 'NLKNguyen/papercolor-theme'
    use { 
        'sonph/onehalf', 
        rtp = 'vim/'
    }
    use 'cocopon/iceberg.vim'
    use 'sainnhe/edge'

    use 'scrooloose/nerdtree'
    use 'tpope/vim-surround'
    use 'tpope/vim-commentary'
    use 'tpope/vim-fugitive'

    use 'godlygeek/tabular'
    -- use 'nvie/vim-flake8'
    use {
        'mfussenegger/nvim-lint',
        config = function()
            require('lint').linters_by_ft = {
                python = {'flake8',}
            }

            vim.cmd("au BufWritePost <buffer> lua require('lint').try_lint()")
        end
    }


    use 'terryma/vim-multiple-cursors'
    use {
        'Raimondi/delimitMate',
        config = function()
            vim.g.delimitMate_expand_cr  = 1
            vim.g.delimitMate_expand_space  = 1
            vim.g.delimitMate_matchpairs = "(:),[:],{:}"
        end
    }

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
                    { name = 'nvim-lsp' },
                    { name = 'luasnip' },
                    { name = 'buffer' },
                },
            }
        end
    }
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-nvim-lsp'
    use { 'saadparwaiz1/cmp_luasnip' }

    use { 
        'neovim/nvim-lspconfig',
        config = function()
            local nvim_lsp = require("lspconfig")

            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)


            nvim_lsp.tsserver.setup {
                capabilities = capabilities,
                root_dir = function()
                    return vim.fn.getcwd()
                end,
                on_attach = function(client)
                    client.resolved_capabilities.document_formatting = false
                    on_attach(client)
                end,
            }
            nvim_lsp.pyright.setup{
                capabilities = capabilities,
            }
            nvim_lsp.gopls.setup{
                capabilities = capabilities,
            }
        end
    }

end)

prequire('packer_compiled')
