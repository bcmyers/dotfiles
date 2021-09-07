local function my_len(table)
  local i = 0
  for _ in pairs(table) do
    i = i + 1
  end
  return i
end

_G.my_colorscheme_index = 1
function _G.my_rotate_colorscheme()
  local colorschemes = {
    -- light
    "base16-google-light",
    "base16-material-lighter",
    "base16-cupertino",
    -- dark
    "base16-greenscreen",
    "base16-default-dark", -- good
    "base16-materia",
    "base16-material-darker", -- good
    "base16-atelier-forest",
    "base16-darktooth",
    "base16-isotope",
    "fahrenheit",
    "garbo", -- good
    "gruvbox",
    "molokai",
    -- Katie likes these
    "base16-outrun-dark",
    "spaceduck"
  }
  local colorscheme = colorschemes[_G.my_colorscheme_index]
  vim.api.nvim_command("colorscheme " .. colorscheme)
  print(colorscheme)
  _G.my_colorscheme_index = _G.my_colorscheme_index + 1
  if _G.my_colorscheme_index > my_len(colorschemes) then
    _G.my_colorscheme_index = 1
  end
end

vim.api.nvim_exec(
  [[
augroup MyColors
    autocmd!
    au ColorScheme * hi LineNr ctermbg=NONE guibg=NONE"
    au ColorScheme * hi NonText ctermbg=NONE guibg=NONE guifg=NONE ctermfg=NONE"
    au ColorScheme * hi Normal ctermbg=NONE guibg=NONE"
    au ColorScheme * hi SignColumn ctermbg=NONE guibg=NONE"
    " au ColorScheme * hi ColorColumn guibg=#000000"
augroup END
]],
  false
)

vim.api.nvim_command("let base16colorspace=256")
vim.api.nvim_command("colorscheme base16-material-darker")
vim.api.nvim_set_keymap("n", "<leader>c", ":lua my_rotate_colorscheme()<CR>", {noremap = true, silent = true})
