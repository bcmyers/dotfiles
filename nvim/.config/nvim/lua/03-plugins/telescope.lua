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
}

local monorepo = "/Users/bcmyers/robinhood/rh"

M.rh_find_files = function()
  local opts = { cwd = monorepo }
  require("telescope.builtin").find_files(opts)
end


M.rh_live_grep = function()
  local opts = { cwd = monorepo }
  require("telescope.builtin").live_grep(opts)
end

vim.api.nvim_set_keymap("n", "<C-n>", ":Telescope find_files<CR>", {noremap = false})

vim.api.nvim_set_keymap("n", "<leader>b",  ":lua require('telescope.builtin').buffers()<CR>",          {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>c",  ":lua require('telescope.builtin').colorscheme()<CR>",      {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>e",  ":lua require('telescope.builtin').diagnostics()<CR>",      {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>f",  ":lua require('telescope.builtin').find_files()<CR>",       {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>gc", ":lua require('telescope.builtin').git_commits()<CR>",      {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>gs", ":lua require('telescope.builtin').git_status()<CR>",       {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>h",  ":lua require('telescope.builtin').help_tags()<CR>",        {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>k",  ":lua require('telescope.builtin').keymaps()<CR>",          {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>l",  ":lua require('telescope.builtin').live_grep()<CR>",        {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>m",  ":lua require('telescope.builtin').man_pages()<CR>",        {noremap = true})

vim.api.nvim_set_keymap("n", "<leader>rf", ":lua require('03-plugins.telescope').rh_find_files()<CR>", {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>rl", ":lua require('03-plugins.telescope').rh_live_grep()<CR>",  {noremap = true})

return M
