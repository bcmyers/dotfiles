M = {}

local default_colorscheme = "base16-material-darker"

local function len(table)
  local i = 0
  for _ in pairs(table) do i = i + 1 end
  return i
end

M._colorscheme_index = 0 + 1

M.rotate_colorscheme = function()
  local colorschemes = {
    default_colorscheme,
    -- light
    "base16-cupertino",
    "base16-google-light",
    "base16-material-lighter",
    -- dark
    "base16-atelier-forest",
    "base16-darktooth",
    "base16-greenscreen",
    "base16-default-dark",
    "base16-isotope",
    "base16-materia",
    "base16-material-darker",
    "base16-outrun-dark",
  }
  M._colorscheme_index = (M._colorscheme_index % len(colorschemes)) + 1
  local colorscheme = colorschemes[M._colorscheme_index]
  vim.api.nvim_command("colorscheme " .. colorscheme)
  print(colorscheme)
end

vim.api.nvim_exec(
  [[
augroup MyColors
    autocmd!
    au ColorScheme * hi LineNr ctermbg=NONE guibg=NONE
    au ColorScheme * hi NonText ctermbg=NONE guibg=NONE guifg=NONE ctermfg=NONE
    au ColorScheme * hi Normal ctermbg=NONE guibg=NONE
    au ColorScheme * hi SignColumn ctermbg=NONE guibg=NONE

    " au ColorScheme * hi ColorColumn guibg=#000000"
augroup END
]],
  false
)

vim.api.nvim_command("let base16colorspace=256")
vim.api.nvim_command("colorscheme " .. default_colorscheme)
vim.api.nvim_set_keymap(
  "n", "<leader><leader>c",
  ":lua require('bcmyers.colors').rotate_colorscheme()<CR>",
  {noremap = true, silent = true}
)

return M
