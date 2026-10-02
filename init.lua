local work_dir = vim.fn.expand '<sfile>:p:h'
vim.opt.rtp:append(work_dir)

local options = require 'options'
options.set_nvim_default_options()

require 'keys'
require 'plugins'
require 'snippets'

if vim.g.neovide then
    require 'neovide'
end

-- vim.cmd 'silent! colorscheme PaperColor'
vim.cmd 'silent! colorscheme edge'

-- if vim.o.background == 'dark' then
--     --     -- vim.api.nvim_set_option('background', 'dark')
--     --     vim.cmd 'hi NvimTreeNormal guibg=NONE ctermbg=NONE'
--     --     vim.cmd 'hi NvimTreeEndOfBuffer guibg=NONE ctermbg=NONE'
--     vim.cmd 'silent! colorscheme onehalfdark'
-- else
--     vim.cmd 'silent! colorscheme onehalflight'
--     --     -- vim.api.nvim_set_option('background', 'light')
-- end

if vim.env.NU_VERSION then
    vim.api.nvim_set_option('shellredir', '| table | save -f')
end
