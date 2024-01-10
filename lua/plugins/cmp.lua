local cmp = require 'cmp'

cmp.setup {
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },

    sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'buffer' },
        -- { name = 'cmp_tabnine' },
    },
    mapping = {
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-Space>'] = cmp.mapping.complete(),
    },
}

local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
    local col = vim.fn.col '.' - 1
    if col == 0 or vim.fn.getline('.'):sub(col, col):match '%s' then
        return true
    else
        return false
    end
end

local luasnip = require 'luasnip'

_G.tab_complete = function()
    print 'tab_complte'
    if vim.fn.pumvisible() == 1 then
        return t '<C-n>'
    elseif luasnip and luasnip.expand_or_jumpable() then
        return t '<Plug>luasnip-expand-or-jump'
    elseif check_back_space() then
        return t '<Tab>'
    elseif cmp.visible() then
        return ''
    end
    return t '<Tab>'
end
_G.s_tab_complete = function()
    if vim.fn.pumvisible() == 1 then
        return t '<C-p>'
    elseif luasnip and luasnip.jumpable(-1) then
        return t '<Plug>luasnip-jump-prev'
    else
        return t '<S-Tab>'
    end
    return ''
end

vim.api.nvim_set_keymap('i', '<Tab>', 'v:lua.tab_complete()', { expr = true })
vim.api.nvim_set_keymap('s', '<Tab>', 'v:lua.tab_complete()', { expr = true })
-- vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
-- vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
vim.api.nvim_set_keymap('i', '<C-E>', '<Plug>luasnip-next-choice', {})
vim.api.nvim_set_keymap('s', '<C-E>', '<Plug>luasnip-next-choice', {})
