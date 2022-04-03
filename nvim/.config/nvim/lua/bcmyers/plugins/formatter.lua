-- Each formatter should return a table that consist of:
--   exe: the program you wish to run
--   args: a table of args to pass
--   stdin: If it should use stdin or not.
--   tempfile_dir: directory for temp file when not using stdin (optional)
--   tempfile_prefix: prefix for temp file when not using stdin (optional)
--   tempfile_postfix: postfix for temp file when not using stdin (optional)

local black = function()
  return {
    exe = "black",
    args = {"-S", "--line-length=79", "-"},
    stdin = true
  }
end

local luafmt = function()
  return {
    exe = "luafmt",
    args = {"--indent-count", 2, "--stdin"},
    stdin = true
  }
end

local prettier = function()
  return {
    exe = "prettier",
    args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0), "--single-quote"},
    stdin = true
  }
end

require("formatter").setup(
  {
    logging = false,
    filetype = {
      html = {prettier},
      javascript = {prettier},
      json = {prettier},
      json5 = {prettier},
      lua = {luafmt},
      markdown = {prettier},
      python = {black},
      typescript = {prettier},
      yaml = {prettier}
    }
  }
)
