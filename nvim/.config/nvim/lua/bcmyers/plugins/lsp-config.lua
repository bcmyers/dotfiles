local lspconfig = require("lspconfig")

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

local on_attach = function(_, bufnr)
  local opts = {noremap = true, silent = true}

  vim.api.nvim_buf_set_keymap(bufnr, "n", "gd",  ":lua vim.lsp.buf.definition()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gD",  ":lua vim.lsp.buf.declaration()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gi",  ":lua vim.lsp.buf.implementation()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gr",  ":lua vim.lsp.buf.rename()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gre", ":lua vim.lsp.buf.references()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gtd", ":lua vim.lsp.buf.type_definition()<CR>", opts)

  vim.api.nvim_buf_set_keymap(bufnr, "n", "[d", ":lua vim.lsp.diagnostic.goto_prev()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "]d", ":lua vim.lsp.diagnostic.goto_next()<CR>", opts)

  vim.api.nvim_buf_set_keymap(bufnr, "n", "K", ":lua vim.lsp.buf.hover()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-k>", ":lua vim.lsp.buf.signature_help()<CR>", opts)

  -- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>e", ":lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", opts)
  -- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>q", ":lua vim.lsp.diagnostic.set_loclist()<CR>", opts)

  require "lsp_signature".on_attach()
end

-- bash
lspconfig.bashls.setup {
  cmd = {"bash-language-server", "start"},
  on_attach = on_attach,
  capabilities = capabilities
}

-- c
lspconfig.clangd.setup {
  cmd = {"clangd", "--background-index"},
  filetypes = {"c", "cpp", "objc", "objcpp"},
  on_attach = on_attach,
  capabilities = capabilities
}

-- docker
lspconfig.dockerls.setup {
  cmd = {"docker-langserver", "--stdio"},
  filetypes = {"Dockerfile", "dockerfile"},
  on_attach = on_attach,
  capabilities = capabilities
}

-- go
lspconfig.gopls.setup {
  cmd = {"gopls"},
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = false,
    }
  },
  filetypes = {"go", "gomod"},
  on_attach = on_attach,
  capabilities = capabilities
}

-- graphql
lspconfig.graphql.setup {
  cmd = {"graphql-lsp", "server", "-m", "stream"},
  filetypes = {"graphql"},
  on_attach = on_attach,
  capabilities = capabilities
}

-- groovy
lspconfig.groovyls.setup {
  cmd = {"java", "-jar", "/Users/bcmyers/opt/groovy-language-server/build/libs/groovy-language-server-all.jar"},
  filetypes = {"groovy"},
  on_attach = on_attach,
  capabilities = capabilities
}

-- html
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
  capabilities = capabilities,
  on_attach = on_attach,
}

-- lua
require'lspconfig'.sumneko_lua.setup {
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {'vim'},
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
}

-- nix
lspconfig.rnix.setup{
  capabilities = capabilities,
  on_attach = on_attach,
}

-- python
lspconfig.pylsp.setup {
  cmd = {"pylsp"},
  filetypes = {"python"},
  settings = {
    pylsp = {
      configurationSources = {"flake8"},
      plugins = {
        black = { enabled = true },
        pyls_isort = { enabled = true },
        pylsp_mypy = { enabled = true, live_mode = true },
        pycodestyle = { enabled = false },
        pyflakes = { enabled = true },
        mccabe = { enabled = false },
      }
    }
  },
  capabilities = capabilities,
  on_attach = on_attach,
}

-- terraform
lspconfig.terraformls.setup {
  cmd = {"terraform-ls", "serve"},
  filetypes = {"terraform"},
  capabilities = capabilities,
  on_attach = on_attach,
}

-- typescript
lspconfig.tsserver.setup {
  cmd = {"typescript-language-server", "--stdio"},
  filetypes = {"javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx"},
  capabilities = capabilities,
  on_attach = on_attach,
}

-- vim
lspconfig.vimls.setup {
  cmd = {"vim-language-server", "--stdio"},
  filetypes = {"vim"},
  capabilities = capabilities,
  on_attach = on_attach,
}

-- yaml
lspconfig.yamlls.setup {
  cmd = {"yaml-language-server", "--stdio"},
  filetypes = {"yaml"},
  capabilities = capabilities,
  on_attach = on_attach,
}

-- rust
require("rust-tools").setup(
  {
    tools = {
      -- rust-tools options

      -- how to execute terminal commands
      -- options right now: termopen / quickfix
      executor = require("rust-tools/executors").termopen,

      -- callback to execute once rust-analyzer is done initializing the workspace
      -- The callback receives one parameter indicating the `health` of the server: "ok" | "warning" | "error"
      on_initialized = nil,

      -- automatically call RustReloadWorkspace when writing to a Cargo.toml file.
      reload_workspace_from_cargo_toml = true,

      -- These apply to the default RustSetInlayHints command
      inlay_hints = {
        -- automatically set inlay hints (type hints)
        -- default: true
        auto = true,

        -- Only show inlay hints for the current line
        only_current_line = false,

        -- whether to show parameter hints with the inlay hints or not
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
        right_align_padding = 7,

        -- The color of the hints
        highlight = "Comment"
      },
      -- options same as lsp hover / vim.lsp.util.open_floating_preview()
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
      },
      -- settings for showing the crate graph based on graphviz and the dot
      -- command
      crate_graph = {
        -- Backend used for displaying the graph
        -- see: https://graphviz.org/docs/outputs/
        -- default: x11
        backend = "x11",
        -- where to store the output, nil for no output stored (relative
        -- path from pwd)
        -- default: nil
        output = nil,
        -- true for all crates.io and external crates, false only the local
        -- crates
        -- default: true
        full = true
      }
    },
    -- all the opts to send to nvim-lspconfig
    -- these override the defaults set by rust-tools.nvim
    -- see https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#rust_analyzer
    server = {
      -- standalone file support
      -- setting it to false may improve startup time
      standalone = true,

      settings = {
        ["rust-analyzer"] = {
          cargo = {
            allFeatures = false
          },
          checkOnSave = {
            allTargets = true,
            command = "clippy",
            enable = true
          }
        }
      },

      capabilities = capabilities,

      on_attach = on_attach,
    }, -- rust-analyer options
    -- debugging stuff
    dap = {
      adapter = {
        type = "executable",
        command = "lldb-vscode",
        name = "rt_lldb",
      },
    },
  }
)

vim.api.nvim_exec(
  [[
augroup FormatSyncAutogroup
  autocmd!
  autocmd BufWritePre *.go,*.py,*.rs lua vim.lsp.buf.formatting_sync(nil, 2000)
augroup END
]],
  true
)
