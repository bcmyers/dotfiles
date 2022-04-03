M = {}

local actions = require("telescope.actions")

require("telescope").setup {
  defaults = {
    cache_picker = {
      num_pickers = -1, -- default 1
      limit_entries = 10000, -- default 1000
    },
    layout_config = {
      horizontal = { height = 0.95, width = 0.95, prompt_position = "top" },
    },
    mappings = {
      n = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-n>"] = actions.close,
        ["<Esc>"] = false,
        ["j"] = actions.move_selection_next,
        ["k"] = actions.move_selection_previous,
      },
      i = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-n>"] = actions.close,
        ["<Esc>"] = nil,
      },
    },
    sorting_strategy = "ascending",
    wrap_results = true,
    vimgrep_arguments = {
      "rg",
      "--color=never", -- required
      "--column",
      "--follow",
      "--hidden",
      "--no-heading",
      "--line-number",
      "--smart-case",
      "--trim",
      "--with-filename",
    },
  },
  pickers = {
    find_files = {
      find_command = {
        "fd",
        "--follow",
        "--hidden",
        -- "--no-ignore",
        "--strip-cwd-prefix",
        "--threads", "12",
        "--type", "f",
        "--exclude", ".git/",
        "--exclude", "*.pyc",
        "--exclude", "target/",
      }
    },
  },
  extensions = {
    file_browser = {
      hidden = true,
    },
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = true,  -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
    },
    ["ui-select"] = {
      require("telescope.themes").get_dropdown({
        -- even more opts
      })
    }
  },
}

require('neoclip').setup({
  continuous_sync = true,
  default_register = '+',
  default_register_macros = 'q',
  enable_persistent_history = true,
  history = 1000,
  keys = {
    telescope = {
      i = {
        select = '<cr>',
        paste = '<c-p>',
        paste_behind = '<c-P>',
      },
      n = {
        select = '<cr>',
        paste = 'p',
        paste_behind = 'P',
      },
    },
  },
})

require("notify").setup({
  -- Animation style (see below for details)
  stages = "fade_in_slide_out",
  -- Function called when a new window is opened, use for changing win settings/config
  on_open = nil,
  -- Function called when a window is closed
  on_close = nil,
  -- Render function for notifications. See notify-render()
  render = "default",
  -- Default timeout for notifications
  timeout = 5000,
  -- Max number of columns for messages
  max_width = nil,
  -- Max number of lines for a message
  max_height = nil,
  -- For stages that change opacity this is treated as the highlight behind the window
  -- Set this to either a highlight group, an RGB hex value e.g. "#000000" or a function returning an RGB code for dynamic values
  background_colour = "#000000",
  -- Minimum width for notification windows
  minimum_width = 50,
  -- Icons for the different levels
  icons = {
    ERROR = "",
    WARN = "",
    INFO = "",
    DEBUG = "",
    TRACE = "✎",
  },
})

require("telescope").load_extension("file_browser")
require("telescope").load_extension('fzf')
require("telescope").load_extension("neoclip")
require("telescope").load_extension("notify")
require("telescope").load_extension("ui-select")
require("telescope").load_extension('zoxide')

local monorepo = "/Users/bcmyers/robinhood/rh"

M.rh_find_files = function()
  local opts = { cwd = monorepo }
  require("telescope.builtin").find_files(opts)
end

M.rh_live_grep = function()
  local opts = { cwd = monorepo }
  require("telescope.builtin").live_grep(opts)
end

vim.api.nvim_set_keymap("n", "<C-n>", ":lua require('telescope.builtin').find_files()<CR>", {noremap = true})

-- To go back, <C-o> ('oh!')
-- To move forward, <C-i>

vim.api.nvim_set_keymap("n", "<leader>ca", ":lua require('telescope.builtin').lsp_code_actions(require('telescope.themes').get_cursor())<CR>", {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>d",  ":lua require('telescope.builtin').lsp_definitions()<CR>",      {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>i",  ":lua require('telescope.builtin').lsp_implementations()<CR>",  {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>t",  ":lua require('telescope.builtin').lsp_type_definitions()<CR>", {noremap = true})

vim.api.nvim_set_keymap("n", "<leader>b",  ":lua require('telescope.builtin').buffers()<CR>",                      {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>c",  ":lua require('telescope.builtin').colorscheme()<CR>",                  {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>cd", ":lua require('telescope').extensions.zoxide.list()<CR>",               {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>e",  ":lua require('telescope.builtin').diagnostics()<CR>",                  {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>f",  ":lua require('telescope').extensions.file_browser.file_browser()<CR>", {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>gc", ":lua require('telescope.builtin').git_commits()<CR>",                  {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>gs", ":lua require('telescope.builtin').git_status()<CR>",                   {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>h",  ":lua require('telescope.builtin').help_tags()<CR>",                    {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>k",  ":lua require('telescope.builtin').keymaps()<CR>",                      {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>l",  ":lua require('telescope.builtin').live_grep()<CR>",                    {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>m",  ":lua require('telescope.builtin').man_pages()<CR>",                    {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>n",  ":lua require('telescope').extensions.notify.notify()<CR>",             {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>y",  ":lua require('telescope').extensions.neoclip.default()<CR>",           {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>z",  ":lua require('telescope').extensions.zoxide.list()<CR>",               {noremap = true})

vim.api.nvim_set_keymap("n", "<leader>rf", ":lua require('bcmyers.plugins.telescope').rh_find_files()<CR>", {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>rl", ":lua require('bcmyers.plugins.telescope').rh_live_grep()<CR>",  {noremap = true})

return M
