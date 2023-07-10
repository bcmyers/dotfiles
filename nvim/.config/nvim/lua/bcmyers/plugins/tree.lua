local status, tree = pcall(require, "nvim-tree")
if not status then
  return
end

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

tree.setup(
  {
    sort_by = "case_sensitive",
    view = {
      width = 30
    },
    renderer = {
      group_empty = true
    },
    filters = {
      dotfiles = false
    },
    git = {
      enable = false
    }
  }
)

vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>", {silent = true})

-- g? toggles help, showing all the mappings and their actions.
