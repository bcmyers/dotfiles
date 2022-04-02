local actions = require("telescope.actions")

require("telescope").setup {
  defaults = {
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--trim"
    },
  },
  pickers = {
    find_files = {
      find_command = { "fd", "--type", "f", "--strip-cwd-prefix" }
    },
  },
  mappings = {
    i = {
      ["<esc>"] = actions.close
    },
  }
}

vim.api.nvim_set_keymap("n", "<leader>fe", ":lua require('telescope.builtin').diagnostics{}<CR>", {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>ff", ":Telescope find_files<CR>", {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>fg", ":Telescope live_grep<CR>", {noremap = true})

vim.api.nvim_set_keymap("n", "<leader>fb", ":Telescope buffers<CR>", {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>fh", ":lua require('telescope.builtin').help_tags()<CR>", {noremap = true})
