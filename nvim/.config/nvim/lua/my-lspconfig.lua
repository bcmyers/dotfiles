local lspconfig = require("lspconfig")

local on_attach = function(client, bufnr)
  local opts = {noremap = true, silent = true}

  vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", ":lua vim.lsp.buf.definition()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gD", ":lua vim.lsp.buf.declaration()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", ":lua vim.lsp.buf.implementation()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", ":lua vim.lsp.buf.references()<CR>", opts)

  vim.api.nvim_buf_set_keymap(bufnr, "n", "[d", ":lua vim.lsp.diagnostic.goto_prev()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "]d", ":lua vim.lsp.diagnostic.goto_next()<CR>", opts)

  vim.api.nvim_buf_set_keymap(bufnr, "n", "K", ":lua vim.lsp.buf.hover()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-k>", ":lua vim.lsp.buf.signature_help()<CR>", opts)

  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>ca", ":lua vim.lsp.buf.code_action()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>e", ":lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>D", ":lua vim.lsp.buf.type_definition()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>rn", ":lua vim.lsp.buf.rename()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>q", ":lua vim.lsp.diagnostic.set_loclist()<CR>", opts)

  require "lsp_signature".on_attach()
end

-- bash
lspconfig.bashls.setup {
  cmd = {"bash-language-server", "start"},
  on_attach = on_attach
}

-- c
lspconfig.clangd.setup {
  cmd = {"/usr/local/opt/llvm/bin/clangd", "--background-index"},
  filetypes = {"c", "cpp", "objc", "objcpp"},
  on_attach = on_attach
}

-- docker
lspconfig.dockerls.setup {
  cmd = {"docker-langserver", "--stdio"},
  filetypes = {"Dockerfile", "dockerfile"},
  on_attach = on_attach
}

-- go
lspconfig.gopls.setup {
  cmd = {"gopls"},
  filetypes = {"go", "gomod"},
  on_attach = on_attach
}

-- graphql
lspconfig.graphql.setup {
  cmd = {"graphql-lsp", "server", "-m", "stream"},
  filetypes = {"graphql"},
  on_attach = on_attach
}

-- groovy
lspconfig.groovyls.setup {
  cmd = {"java", "-jar", "/Users/bcmyers/opt/groovy-language-server/build/libs/groovy-language-server-all.jar"},
  filetypes = {"groovy"},
  on_attach = on_attach
}

-- html
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
lspconfig.html.setup {
  cmd = {"vscode-html-language-server", "--stdio"},
  filetypes = {"html"},
  capabilities = capabilities,
  on_attach = on_attach
}

-- json
lspconfig.jsonls.setup {
  cmd = {"vscode-json-language-server", "--stdio"},
  filetypes = {"json"},
  commands = {
    Format = {
      function()
        vim.lsp.buf.range_formatting({}, {0, 0}, {vim.fn.line("$"), 0})
      end
    }
  },
  on_attach = on_attach
}

-- lua
local system_name
if vim.fn.has("mac") == 1 then
  system_name = "macOS"
elseif vim.fn.has("unix") == 1 then
  system_name = "Linux"
elseif vim.fn.has("win32") == 1 then
  system_name = "Windows"
else
  print("Unsupported system for sumneko")
end
local sumneko_root_path = "/Users/bcmyers/opt/lua-language-server"
local sumneko_binary = sumneko_root_path .. "/bin/" .. system_name .. "/lua-language-server"
local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")
lspconfig.sumneko_lua.setup {
  cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"},
  filetypes = {"lua"},
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = "LuaJIT",
        -- Setup your lua path
        path = runtime_path
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {"use", "vim"}
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true)
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false
      }
    }
  },
  on_attach = on_attach
}

-- python
lspconfig.pylsp.setup {
  cmd = {"pylsp"},
  filetypes = {"python"},
  settings = {
    pylsp = {
      configurationSources = {"flake8"},
      plugins = {
        pycodestyle = {
          enabled = false
        }
      }
    }
  },
  on_attach = function(client, bufnr)
    local opts = {noremap = true, silent = true}
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>f", ":lua vim.lsp.buf.formatting()<CR>", opts)
    on_attach(client, bufnr)
  end
}

-- terraform
lspconfig.terraformls.setup {
  cmd = {"terraform-ls", "serve"},
  filetypes = {"terraform"},
  on_attach = on_attach
}

-- typescript
lspconfig.tsserver.setup {
  cmd = {"typescript-language-server", "--stdio"},
  filetypes = {"javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx"},
  on_attach = on_attach
}

-- vim
lspconfig.vimls.setup {
  cmd = {"vim-language-server", "--stdio"},
  filetypes = {"vim"},
  on_attach = on_attach
}

-- yaml
lspconfig.yamlls.setup {
  cmd = {"yaml-language-server", "--stdio"},
  filetypes = {"yaml"},
  on_attach = on_attach
}

-- rust
require("rust-tools").setup(
  {
    tools = {
      -- rust-tools options
      -- automatically set inlay hints (type hints)
      -- There is an issue due to which the hints are not applied on the first
      -- opened file. For now, write to the file to trigger a reapplication of
      -- the hints or just run :RustSetInlayHints.
      -- default: true
      autoSetHints = true,
      -- whether to show hover actions inside the hover window
      -- this overrides the default hover handler so something like lspsaga.nvim's hover would be overriden by this
      -- default: true
      hover_with_actions = true,
      -- These apply to the default RustRunnables command
      runnables = {
        -- whether to use telescope for selection menu or not
        -- default: true
        use_telescope = true

        -- rest of the opts are forwarded to telescope
      },
      -- These apply to the default RustSetInlayHints command
      inlay_hints = {
        -- wheter to show parameter hints with the inlay hints or not
        -- default: true
        show_parameter_hints = true,
        -- prefix for parameter hints
        -- default: "<-"
        parameter_hints_prefix = "<- ",
        -- prefix for all the other hints (type, chaining)
        -- default: "=>"
        other_hints_prefix = "=> ",
        -- whether to align to the lenght of the longest line in the file
        max_len_align = false,
        -- padding from the left if max_len_align is true
        max_len_align_padding = 1,
        -- whether to align to the extreme right or not
        right_align = false,
        -- padding from the right if right_align is true
        right_align_padding = 7
      },
      hover_actions = {
        -- the border that is used for the hover window
        -- see vim.api.nvim_open_win()
        border = {
          {"╭", "FloatBorder"},
          {"─", "FloatBorder"},
          {"╮", "FloatBorder"},
          {"│", "FloatBorder"},
          {"╯", "FloatBorder"},
          {"─", "FloatBorder"},
          {"╰", "FloatBorder"},
          {"│", "FloatBorder"}
        },
        -- whether the hover action window gets automatically focused
        -- default: false
        auto_focus = false
      }
    },
    -- all the opts to send to nvim-lspconfig
    -- these override the defaults set by rust-tools.nvim
    -- see https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#rust_analyzer
    server = {
      -- ["rust-analyzer"] = {
      --   cargo = {
      --     allFeatures = true,
      --   },
      -- },
      -- ["rust-analyzer.checkOnSave.allFeatures"] = true,
      on_attach = function(client, bufnr)
        local opts = {noremap = true, silent = true}
        vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>f", ":lua vim.lsp.buf.formatting()<CR>", opts)
        on_attach(client, bufnr)
      end
    } -- rust-analyer options
  }
)

-- vim.api.nvim_exec(
--   [[
-- augroup FormatSyncAutogroup
--   autocmd!
--   autocmd BufWritePre *.py,*.rs lua vim.lsp.buf.formatting_sync(nil, 2000)
-- augroup END
-- ]],
--   true
-- )
