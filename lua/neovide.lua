if vim.fn.has 'macunix' then
    vim.o.guifont = 'SFMono Nerd Font:h17'
else
    vim.o.guifont = 'Ubuntu Mono Ligaturized:h18'
    vim.g.neovide_transparency = 0.8
    vim.env.DARK_MODE = 1
end
