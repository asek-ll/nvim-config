require('formatter').setup {
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
        go = {
            require('formatter.filetypes.go').gofmt,
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
    },
}
