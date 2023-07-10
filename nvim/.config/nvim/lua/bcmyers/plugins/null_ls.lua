local status, null_ls = pcall(require, "null-ls")
if not status then
  return
end

local status_, mason_null_ls = pcall(require, "mason-null-ls")
if not status_ then
  return
end

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

null_ls.setup({
  sources = {
    null_ls.builtins.diagnostics.buildifier,
    null_ls.builtins.diagnostics.cpplint,
    null_ls.builtins.diagnostics.hadolint,
    null_ls.builtins.formatting.buildifier,
    null_ls.builtins.formatting.clang_format,
    null_ls.builtins.formatting.goimports,
    null_ls.builtins.formatting.just,
    null_ls.builtins.formatting.prettier,
  },
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({
            bufnr = bufnr,
            filter = function(client_)
              return client_.name == "null-ls"
            end
          })
        end,
      })
    end
  end,
})

mason_null_ls.setup({
  ensure_installed = nil,
  automatic_installation = true,
})
