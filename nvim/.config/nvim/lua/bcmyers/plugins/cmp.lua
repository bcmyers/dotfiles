local cmp = require('cmp')
local compare = require('cmp.config.compare')
local types = require("cmp.types")
local lspkind = require("lspkind")
local str = require("cmp.utils.str")

lspkind.init {
  mode = 'symbol_text',
  symbol_map = {
    Text = "",
    Method = "",
    Function = "",
    Constructor = "",
    Field = "ﰠ",
    Variable = "",
    Class = "ﴯ",
    Interface = "",
    Module = "",
    Property = "ﰠ",
    Unit = "塞",
    Value = "",
    Enum = "",
    Keyword = "",
    Snippet = "",
    Color = "",
    File = "",
    Reference = "",
    Folder = "",
    EnumMember = "",
    Constant = "",
    Struct = "פּ",
    Event = "",
    Operator = "",
    TypeParameter = ""
  },
}

local compare_kind = function(entry1, entry2)
  local kind1 = entry1:get_kind()
  kind1 = kind1 == types.lsp.CompletionItemKind.Text and 100 or kind1
  local kind2 = entry2:get_kind()
  kind2 = kind2 == types.lsp.CompletionItemKind.Text and 100 or kind2
  if kind1 ~= kind2 then
    if kind1 == types.lsp.CompletionItemKind.Snippet then
      return false
    end
    if kind2 == types.lsp.CompletionItemKind.Snippet then
      return true
    end
    local diff = kind1 - kind2
    if diff < 0 then
      return true
    elseif diff > 0 then
      return false
    end
  end
end

cmp.setup({
  experimental = {
    ghost_text = true,
  },
  formatting = {
    fields = { cmp.ItemField.Kind, cmp.ItemField.Abbr, cmp.ItemField.Menu },
    format = lspkind.cmp_format({
      mode = "symbol",
      maxwidth = 60,
      before = function (entry, vim_item)
        local word = entry:get_insert_text()
        if entry.completion_item.insertTextFormat == types.lsp.InsertTextFormat.Snippet then
          word = vim.lsp.util.parse_snippet(word)
        end
        word = str.oneline(word)
        vim_item.abbr = word
        return vim_item
      end
    })
  },
  mapping = {
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    ["<Right>"] = cmp.mapping {
      i = cmp.mapping.confirm { select = true },
    },
    ["<Tab>"] = cmp.mapping {
      i = cmp.mapping.confirm { select = true },
    },
    ["<C-j>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "s" }),
    ["<C-k>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "s" }),
    -- Not really used...
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
  },
  sorting = {
    priority_weight = 2,
    comparators = {
      compare.offset,
      compare.exact,
      compare.score,
      compare.recently_used,
      compare.locality,
      -- compare.scopes,
      compare_kind,
      compare.sort_text,
      compare.length,
      compare.order,
    },
  },
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
    end,
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'nvim_lua' },
    { name = "crates" },
    { name = "path" },
    { name = 'vsnip' },
  }, {
    { name = 'buffer', keyword_length = 5 },
  }),
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
})

-- `/` cmdline setup.
cmp.setup.cmdline('/', {
  sources = {
    { name = 'buffer', keyword_length = 5 }
  }
})

-- `:` cmdline setup.
cmp.setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline', keyword_length = 5 }
  })
})

-- insert `(` after select function or method item
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done { map_char = { tex = "" } })
