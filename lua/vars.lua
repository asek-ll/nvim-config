local M = {}

-- M.cwd = vim.fn.expand '<sfile>:p:h'
M.cwd = vim.fs.dirname(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2):match("(.*[/\\])")))

return M
