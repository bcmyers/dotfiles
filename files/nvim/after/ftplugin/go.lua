vim.bo.expandtab = false -- use hard tabs
vim.bo.shiftwidth = 4
vim.bo.smartindent = true -- insert indents automatically
vim.bo.tabstop = 4

vim.opt_local.listchars = {
	eol = nil,
	extends = ">",
	lead = "-",
	nbsp = "·",
	precedes = "<",
	space = nil,
	tab = "  ",
	trail = "·",
}
