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
    },
}
