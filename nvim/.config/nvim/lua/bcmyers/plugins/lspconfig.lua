local status, lspconfig = pcall(require, "lspconfig")
if not status then
  return
end

local status_, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not status_ then
  return
end

local status__, rust_tools = pcall(require, "rust-tools")
if not status__ then
  return
end

local capabilities = cmp_nvim_lsp.default_capabilities()

vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set("n", "gc", vim.lsp.buf.incoming_calls, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)

    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)

    vim.keymap.set({ 'n', 'v' }, "<space>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', "<space>f", function()
      vim.lsp.buf.format { async = true }
    end, opts)
    vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
  end,
})

-- bash
lspconfig.bashls.setup {
  cmd = {"bash-language-server", "start"},
  capabilities = capabilities
}

-- c
lspconfig.clangd.setup {
  cmd = {"clangd", "--background-index"},
  filetypes = {"c", "cpp", "objc", "objcpp"},
  capabilities = capabilities
}

-- docker
lspconfig.dockerls.setup {
  cmd = {"docker-langserver", "--stdio"},
  filetypes = {"Dockerfile", "dockerfile"},
  capabilities = capabilities
}

-- go
lspconfig.gopls.setup {
  cmd = {"gopls"},
  settings = {
    gopls = {
      analyses = {
        unusedparams = true
      },
      staticcheck = false
    }
  },
  filetypes = {"go", "gomod"},
  capabilities = capabilities
}

-- groovy
lspconfig.groovyls.setup {
  cmd = {"java", "-jar", "/Users/bcmyers/opt/groovy-language-server/build/libs/groovy-language-server-all.jar"},
  filetypes = {"groovy"},
  capabilities = capabilities
}

-- html
lspconfig.html.setup {
  cmd = {"vscode-html-language-server", "--stdio"},
  filetypes = {"html"},
  capabilities = capabilities,
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
}

-- jsonnet
lspconfig.jsonnet_ls.setup {
  capabilities = capabilities
}

-- lua
lspconfig.lua_ls.setup {
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = "LuaJIT",
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {"vim"}
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false
      }
    }
  },
  capabilities = capabilities
}

-- nix
lspconfig.rnix.setup {
  capabilities = capabilities,
}

-- python
lspconfig.pylsp.setup {
  cmd = {"pylsp"},
  filetypes = {"python"},
  settings = {
    pylsp = {
      plugins = {
        black = {
          enabled = true,
          line_length = "79"
        },
        pyls_isort = {enabled = false},
        pylsp_mypy = {enabled = true, live_mode = true},
        pycodestyle = {enabled = false},
        pyflakes = {enabled = false},
        mccabe = {enabled = false}
      }
    }
  },
  capabilities = capabilities,
}

-- terraform
lspconfig.terraformls.setup {
  cmd = {"terraform-ls", "serve"},
  filetypes = {"terraform"},
  capabilities = capabilities,
}

-- typescript
lspconfig.tsserver.setup {
  cmd = {"typescript-language-server", "--stdio"},
  filetypes = {"javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx"},
  capabilities = capabilities,
}

-- vim
lspconfig.vimls.setup {
  cmd = {"vim-language-server", "--stdio"},
  filetypes = {"vim"},
  capabilities = capabilities,
}

-- yaml
lspconfig.yamlls.setup {
  cmd = {"yaml-language-server", "--stdio"},
  filetypes = {"yaml"},
  capabilities = capabilities,
}

lspconfig.ruff_lsp.setup {
  init_options = {
    settings = {
      args = {"--config", "/Users/brian.myers/robinhood/rh2/devx/linters/devx-ruff/data/ruff.toml"}
    }
  },
  capabilities = capabilities
}

-- rust
rust_tools.setup(
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
    }, -- rust-analyer options
    -- debugging stuff
    dap = {
      adapter = {
        type = "executable",
        command = "lldb-vscode",
        name = "rt_lldb"
      }
    }
  }
)

vim.api.nvim_exec(
  [[
augroup FormatSyncAutogroup
  autocmd!
  autocmd BufWritePre *.go,*.py,*.rs lua vim.lsp.buf.format(nil, 2000)
augroup END
]],
  true
)
