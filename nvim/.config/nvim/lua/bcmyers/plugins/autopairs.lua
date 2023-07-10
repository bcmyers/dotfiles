local status, autopairs = pcall(require, "nvim-autopairs")
if not status then
  return
end

local status_, autopairs_cmp = pcall(require, "nvim-autopairs.completion.cmp")
if not status_ then
  return
end

local status__, cmp = pcall(require, "cmp")
if not status__ then
  return
end

autopairs.setup(
  {
    check_ts = true, -- enable treesitter
    disable_filetype = {"TelescopePrompt"},
    enable_afterquote = true, -- add bracket pairs after quote
    enable_check_bracket_line = true, --- check bracket in same line
    enable_moveright = true,
    ignored_next_char = string.gsub([[ [%w%%%'%[%"%.] ]], "%s+", ""),
    ts_config = {
      lua = {"string"}, -- don't add pairs in lua string treesitter nodes
      javascript = {"template_string"}, -- don't add pairs in javscript template_string treesitter nodes
      java = false -- don't check treesitter on java
    }
  }
)

-- make autopairs and completion work together
cmp.event:on("confirm_done", autopairs_cmp.on_confirm_done())
