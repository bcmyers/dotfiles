local LEADER = " "

vim.api.nvim_exec([[
filetype plugin indent on
syntax on
]], false)

vim.g.mapleader = LEADER
vim.g.python_host_prog = "~/.pyenv/shims/python2"
vim.g.python3_host_prog = "~/.pyenv/shims/python3"

vim.o.autoindent = true
vim.o.autoread = true
vim.o.backup = false
vim.o.belloff = "all"
vim.o.clipboard = "unnamedplus"
vim.o.cmdheight = 1
vim.o.colorcolumn = "80,100"
vim.o.completeopt = "menu,menuone,noselect"
vim.o.emoji = false
vim.o.expandtab = true -- Use spaces instead of tabs
vim.o.formatoptions = "cjnqr"
vim.o.guicursor = "a:ver25-blinkon0,r:hor25-blinkon0"
vim.o.hidden = true
vim.o.ignorecase = true
vim.o.list = true
vim.o.modeline = true
vim.o.modelines = 10
vim.o.mouse = "a"
vim.o.mousefocus = true
vim.o.number = true
vim.o.scrolloff = 3 -- Minimum number of screen lines to keep above and below the cursor
vim.o.shiftwidth = 4 -- Size of an indent
vim.o.shortmess = "filnxtToOFc"
vim.o.showmatch = true -- Show matching parentheses
vim.o.signcolumn = "yes" -- Always show signcolumns
vim.o.smartcase = true
vim.o.smartindent = true -- Insert indents automatically
vim.o.softtabstop = 0
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.swapfile = false
vim.o.tabstop = 4 -- Number of spaces tabs count for
vim.o.termguicolors = true -- True color support
vim.o.title = true
vim.o.titlestring = "%F"
vim.o.updatetime = 100
vim.o.undodir = "/tmp"
vim.o.undofile = true
vim.o.wildignorecase = true
vim.o.wildmode = "longest,list:longest,full"
vim.o.writebackup = false

vim.opt.listchars = {
  eol = nil,
  extends = '>',
  multispace = nil,
  nbsp = "·",
  precedes = '<',
  space = " ",
  tab = ">·",
  trail = "·",
}

vim.wo.conceallevel = 0
vim.wo.wrap = false

-- disable unused builtins
vim.g.loaded_2html_plugin = 1
vim.g.loaded_getscript = 1
vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_gzip = 1
vim.g.loaded_logiPat = 1
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrwSettings = 1
vim.g.loaded_rrhelper = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1

vim.api.nvim_set_keymap("n", "n", "nzzzv", {noremap = true})
vim.api.nvim_set_keymap("n", "N", "Nzzzv", {noremap = true})

-- Save and reload current file
vim.api.nvim_set_keymap("n", "<leader><leader>x", ":w<CR>:source %<CR>", {noremap = true})

-- Better tabbing
vim.api.nvim_set_keymap("v", "<", "<gv", {noremap = true})
vim.api.nvim_set_keymap("v", ">", ">gv", {noremap = true})

-- Better verticle movement for wrapped lines
vim.api.nvim_set_keymap("n", "j", "gj", {noremap = true})
vim.api.nvim_set_keymap("n", "k", "gk", {noremap = true})

vim.api.nvim_exec(
  [[
augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=1000}
augroup END

augroup jenkinsfile
    autocmd!
    au BufNewFile,BufRead Jenkinsfile* setf groovy
augroup END

augroup remember_cursor_position
    autocmd!
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\""
augroup END
]],
  false
)
