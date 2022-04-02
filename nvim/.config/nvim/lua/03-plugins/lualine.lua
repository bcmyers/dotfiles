require "lualine".setup {
  options = {
    icons_enabled = true,
    theme = "nightfly",
    component_separators = {"|", "|"},
    section_separators = {"", ""},
    disabled_filetypes = {}
  },
  sections = {
    lualine_a = {"mode"},
    lualine_b = {
      {
        "filename",
        file_status = true, -- displays file status (readonly status, modified status)
        path = 1 -- 0 = just filename, 1 = relative path, 2 = absolute path
      }
    },
    lualine_c = {},
    lualine_x = {},
    lualine_y = {{"diagnostics", sources = {"nvim_diagnostic"}}, "branch", "encoding", "fileformat", "location"},
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
  extensions = {}
}
