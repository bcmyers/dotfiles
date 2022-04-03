require("nvim-autopairs").setup(
  {
    disable_filetype = {"TelescopePrompt"},
    ignored_next_char = string.gsub([[ [%w%%%'%[%"%.] ]], "%s+", ""),
    enable_moveright = true,
    enable_afterquote = true, -- add bracket pairs after quote
    enable_check_bracket_line = true, --- check bracket in same line
    check_ts = false
  }
)
