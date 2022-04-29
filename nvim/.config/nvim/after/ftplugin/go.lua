vim.bo.expandtab = false -- use spaces for tabs
vim.bo.shiftwidth = 4
vim.bo.smartindent = true -- insert indents automatically
vim.bo.tabstop = 4

vim.wo.colorcolumn = "80,100"

vim.opt_local.listchars = {
  eol = nil,
  extends = '>',
  lead = "-",
  nbsp = "·",
  precedes = '<',
  space = nil,
  tab = "  ",
  trail = "·",
}
