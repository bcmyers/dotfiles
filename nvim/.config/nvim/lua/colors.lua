local function random_colorscheme()
  local colorschemes = {
    -- light
    -- 'base16-google-light',
    -- 'base16-material-lighter',
    -- "base16-cupertino"

    -- dark
    -- "base16-greenscreen"
    -- "base16-default-dark",
    -- "base16-materia",
    "base16-material-darker"
    -- 'base16-atelier-forest',
    -- 'base16-darktooth',
    -- 'base16-isotope',
    -- "fahrenheit"
    -- 'garbo',
    -- 'gruvbox',
    -- 'molokai',

    -- Katie likes these
    -- "base16-outrun-dark"
    -- 'spaceduck',
  }
  math.randomseed(os.time())
  return colorschemes[math.random(#colorschemes)]
end

vim.api.nvim_command("let base16colorspace=256")
vim.api.nvim_command("colorscheme " .. random_colorscheme())
