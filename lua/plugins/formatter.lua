require('formatter').setup {
    -- log_level = vim.log.levels.TRACE,
    filetype = {
        lua = {
            function()
                local Path = require 'plenary.path'
                local cwd = require('vars').cwd
                return {
                    exe = 'stylua',
                    args = {
                        '--config-path ' .. Path:new(cwd, 'lua', 'stylua.toml'):expand(),
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
                local bufnr = vim.fn.bufnr()
                return {
                    exe = 'prettier',
                    args = {
                        '--parser',
                        'babel',
                        '--tab-width',
                        vim.bo[bufnr].shiftwidth,
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
            require('formatter.filetypes.python').ruff,
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
        -- go = {
        --     require('formatter.filetypes.go').gofmt,
        -- },
        go = {
            function()
                return {
                    exe = 'ya',
                    args = {
                        'tool',
                        'yoimports',
                        '-w',
                    },
                    stdin = false,
                    -- no_append = true,
                }
            end,
        },
        yaml = {
            function()
                return {
                    exe = 'prettier',
                    args = {
                        '--parser',
                        'yaml',
                    },
                    stdin = true,
                }
            end,
        },
        xml = {
            function()
                local bufnr = vim.fn.bufnr()
                return {
                    exe = 'prettier',
                    args = {
                        '--parser',
                        'html',
                        '--print-width',
                        140,
                        '--bracket-same-line',
                        '--html-whitespace-sensitivity',
                        'ignore',
                        '--tab-width',
                        vim.bo[bufnr].shiftwidth,
                    },
                    stdin = true,
                }
            end,
        },
        sql = {
            require('formatter.filetypes.sql').pgformat,
        },
        terraform = {
            require('formatter.filetypes.terraform').terraformfmt,
        },
        racket = {
            function()
                return {
                    exe = 'raco',
                    args = {
                        'fmt',
                    },
                    stdin = true,
                }
            end,
        },
        toml = {
            require('formatter.filetypes.toml').taplo,
        },
        nix = {
            require('formatter.filetypes.nix').nixpkgs_fmt,
        },
        proto = {
            require('formatter.filetypes.proto').buf_format,
        },
        haskell = {
            require('formatter.filetypes.haskell').fourmolu,
        },
    },
}
