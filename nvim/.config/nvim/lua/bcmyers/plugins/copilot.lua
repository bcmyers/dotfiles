local status, copilot = pcall(require, "copilot")
if not status then
  return
end

local status_, copilot_cmp = pcall(require, "copilot_cmp")
if not status_ then
  return
end

local status__, cmp = pcall(require, "cmp")
if not status__ then
  return
end

copilot.setup(
  {
    panel = {enabled = false},
    -- TODO: potentially turn this off
    suggestion = {
      enabled = true,
      auto_trigger = true,
      keymap = {
        accept = "<c-u>",
        accept_word = false,
        accept_line = false,
        next = "<c-q>",
        prev = "<c-w>",
        dismiss = "c-]"
      }
    },
    filetypes = {
      cvs = false,
      gitcommit = false,
      gitrebase = false,
      help = false,
      hgcommit = false,
      markdown = false,
      svn = false,
      yaml = false,
      ["."] = false
    },
    copilot_node_command = "node" -- Node.js version must be > 16.x
  }
)

copilot_cmp.setup()

cmp.event:on(
  "menu_opened",
  function()
    vim.b.copilot_suggestion_hidden = true
  end
)

cmp.event:on(
  "menu_closed",
  function()
    vim.b.copilot_suggestion_hidden = false
  end
)
