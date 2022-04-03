require "lualine".setup {
  options = {
    icons_enabled = true,
    theme = "nightfly",
    component_separators = {"|", "|"},
    section_separators = {"", ""},
    disabled_filetypes = {}
  },
  sections = {
    lualine_a = {
      "mode",
    },
    lualine_b = {
      "branch",
    },
    lualine_c = {
      {
        "filename",
        file_status = true, -- displays file status (readonly status, modified status)
        path = 2 -- 0 = just filename, 1 = relative path, 2 = absolute path
      }
    },
    lualine_x = {},
    lualine_y = {
      -- {
      --   "lsp_progress",
      --   display_components = {"spinner"},
      --   separators = {
      --     spinner = { pre = "", post = "" },
      --   },
      --   spinner_symbols = { "🌑", "🌒", "🌓", "🌔", "🌕", "🌖", "🌗", "🌘" },
      -- },
      {"diagnostics", sources = {"nvim_lsp"}, always_visible = true},
      -- "encoding",
      -- "fileformat",
      "location",
    },
    lualine_z = {"filetype"}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {"filename"},
    lualine_x = {"location"},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  extensions = {"fzf", "nerdtree"}
}
