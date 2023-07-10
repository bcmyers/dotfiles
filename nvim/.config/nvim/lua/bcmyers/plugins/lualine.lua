local status, lualine = pcall(require, "lualine")
if not status then
  return
end

lualine.setup(
  {
    options = {
      always_divide_middle = false,
      icons_enabled = true,
      theme = "OceanicNext",
      component_separators = {"|", "|"},
      section_separators = {"", ""},
      disabled_filetypes = {
        statusline = {},
        winbar = {}
      },
      globalstatus = true
    },
    sections = {
      lualine_a = {
        "mode"
      },
      lualine_b = {},
      lualine_c = {
        {
          "filename",
          file_status = false, -- displays file status (readonly status, modified status)
          -- 0: Just the filename
          -- 1: Relative path
          -- 2: Absolute path
          -- 3: Absolute path, with tilde as the home directory
          -- 4: Filename and parent dir, with tilde as the home directory
          path = 3
        }
      },
      lualine_x = {},
      lualine_y = {"location"},
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
    extensions = {"fzf", "lazy", "nvim-dap-ui", "nvim-tree"}
  }
)
