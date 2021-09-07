local g = vim.g

g.nvim_tree_add_trailing = 1 -- append a trailing slash to folder names
g.nvim_tree_auto_close = 0 -- closes the tree when it's the last window
g.nvim_tree_auto_open = 1 -- opens the tree when typing `vim $DIR` or `vim`
g.nvim_tree_disable_netrw = 1 -- disables netrw
g.nvim_tree_gitignore = 0
g.nvim_tree_quit_on_open = 0 -- closes the tree when you open a file
g.nvim_tree_ignore = {".DS_Store", ".mypy_cache"}
g.nvim_tree_indent_markers = 1 -- shows indent markers when folders are open
g.nvim_tree_group_empty = 0 -- compact folders that only contain a single folder into one node in the file tree
g.nvim_tree_lsp_diagnostics = 0 -- will show lsp diagnostics in the signcolumn. See :help nvim_tree_lsp_diagnostics
g.nvim_tree_side = "left"
g.nvim_tree_width = 30

-- list of filenames that gets highlighted with NvimTreeSpecialFile
g.nvim_tree_special_files = {
  "README.md",
  "Makefile"
}

g.nvim_tree_show_icons = {
  git = 1,
  files = 1,
  folder_arrows = 1,
  folders = 1
}

g.nvim_tree_icons = {
  default = "",
  symlink = "",
  git = {
    unstaged = "✗",
    staged = "✓",
    unmerged = "",
    renamed = "➜",
    untracked = "★",
    deleted = "",
    ignored = "◌"
  },
  folder = {
    arrow_open = "",
    arrow_closed = "",
    default = "",
    open = "",
    empty = "",
    empty_open = "",
    symlink = "",
    symlink_open = ""
  },
  lsp = {
    hint = "",
    info = "",
    warning = "",
    error = ""
  }
}

vim.api.nvim_set_keymap("n", "<C-n>", ":NvimTreeToggle<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<leader>r", ":NvimTreeRefresh<CR>", {noremap = true, silent = true})
