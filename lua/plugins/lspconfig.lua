local capabilities = require('cmp_nvim_lsp').default_capabilities()

local opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap('n', '<Leader>ld', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
vim.api.nvim_set_keymap('n', '<Leader>ll', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

local on_attach = function(client, bufnr)
    -- vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    --
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)

    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>le', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>ls', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>lwa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>lwr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    vim.api.nvim_buf_set_keymap(
        bufnr,
        'n',
        '<leader>lwl',
        '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>',
        opts
    )
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lr', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>la', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lg', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lf', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end

vim.lsp.config('denols', {
    on_attach = on_attach,
    root_markers = {
        'deno.json',
        'deno.jsonc',
    },
    capabilities = capabilities,
})

vim.lsp.config('ts_ls', {
    on_attach = on_attach,
    root_markers = {
        'package.json',
    },
    single_file_support = false,
    capabilities = capabilities,
})

vim.lsp.config('pyright', {
    capabilities = capabilities,
    on_attach = on_attach,
})
-- nvim_lsp.gopls.setup {
--     capabilities = capabilities,
--     on_attach = on_attach,
-- }
vim.lsp.config('gopls', {
    -- cmd = { 'ya', 'tool', 'gopls' },
    capabilities = capabilities,
    on_attach = on_attach,
})

vim.lsp.config('clangd', {
    capabilities = capabilities,
    on_attach = on_attach,
})

vim.lsp.config('rust_analyzer', {
    capabilities = capabilities,
    on_attach = on_attach,
})

vim.lsp.config('lua_ls', {
    settings = {
        Lua = {
            runtime = {
                version = '5.4',
            },
            diagnostics = {
                globals = { 'vim' },
            },
            telemetry = {
                enable = false,
            },
        },
    },
    on_attach = on_attach,
})

vim.lsp.config('racket_langserver', {
    capabilities = capabilities,
    on_attach = on_attach,
})

vim.lsp.config('terraformls', {
    capabilities = capabilities,
    on_attach = on_attach,
})

vim.lsp.enable 'denols'
vim.lsp.enable 'ts_ls'
vim.lsp.enable 'pyright'
vim.lsp.enable 'gopls'
vim.lsp.enable 'clangd'
vim.lsp.enable 'rust_analyzer'
vim.lsp.enable 'lua_ls'
vim.lsp.enable 'racket_langserver'
vim.lsp.enable 'terraformls'
vim.lsp.enable 'jsonnet_ls'
