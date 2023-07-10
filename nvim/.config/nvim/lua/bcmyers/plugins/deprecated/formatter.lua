-- Good example:
-- https://github.com/ahmedelgabri/dotfiles/blob/0ce9a2704e4cd25be591d635032839a51317bcdc/config/nvim/lua/_/config/formatter.lua

-- Each formatter should return a table that consist of:
--   exe: the program you wish to run
--   args: a table of args to pass
--   stdin: If it should use stdin or not.
--   tempfile_dir: directory for temp file when not using stdin (optional)
--   tempfile_prefix: prefix for temp file when not using stdin (optional)
--   tempfile_postfix: postfix for temp file when not using stdin (optional)

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
    args = {
      "--config-precedence",
      "prefer-file",
      "--single-quote",
      "--no-bracket-spacing",
      "--prose-wrap",
      "always",
      "--arrow-parens",
      "always",
      "--trailing-comma",
      "all",
      "--no-semi",
      "--end-of-line",
      "lf",
      "--print-width",
      vim.bo.textwidth,
      "--stdin-filepath",
      vim.fn.shellescape(vim.api.nvim_buf_get_name(0))
    },
    stdin = true
  }
end

local prettierSh = function()
  return {
    exe = "prettier",
    args = {
      "--stdin-filepath",
      vim.fn.shellescape(vim.api.nvim_buf_get_name(0))
    },
    stdin = true
  }
end

-- local shfmt = function()
--   return {
--     exe = "shfmt",
--     args = {
--       "-i",
--       "2",
--       "-sr",
--       "-"
--     },
--     stdin = true
--   }
-- end

require("formatter").setup(
  {
    logging = false,
    filetype = {
      bash = {prettierSh},
      css = {prettier},
      graphql = {prettier},
      html = {prettier},
      javascript = {prettier},
      javascriptreact = {prettier},
      ["javascript.jsx"] = {prettier},
      json = {prettier},
      json5 = {prettier},
      jsonc = {prettier},
      less = {prettier},
      lua = {luafmt},
      markdown = {prettier},
      scss = {prettier},
      sh = {prettierSh},
      typescript = {prettier},
      typescriptreact = {prettier},
      ["typescript.tsx"] = {prettier},
      vue = {prettier},
      yaml = {prettier}
    }
  }
)

local group = "FormatAutogroup"
vim.api.nvim_create_augroup(group, {clear = true})
vim.api.nvim_create_autocmd(
  "BufWritePost",
  {
    group = group,
    pattern = {
      ".bashrc",
      ".bash_profile",
      ".bash_secret",
      "*.json",
      "*.json5",
      "*.lua",
      "*.yaml"
      -- "*.yml"
    },
    command = "FormatWrite"
  }
)
