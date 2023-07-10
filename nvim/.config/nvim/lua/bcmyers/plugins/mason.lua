local status, mason = pcall(require, "mason")
if not status then
  return
end

local status_, mason_lspconfig = pcall(require, "mason-lspconfig")
if not status_ then
  return
end

mason.setup()

mason_lspconfig.setup()
