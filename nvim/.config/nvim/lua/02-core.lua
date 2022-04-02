local LEADER = " "

local g = vim.g
local o = vim.opt
local wo = vim.wo

vim.api.nvim_exec([[
filetype plugin indent on
syntax on
]], false)

o.autoindent = true
o.autoread = true
o.backup = false
o.belloff = "all"
o.clipboard = "unnamedplus"
o.cmdheight = 2
o.colorcolumn = "80,100"
o.emoji = false
o.expandtab = true -- Use spaces instead of tabs
o.formatoptions = "cjnqr"
o.guicursor = "a:ver25-blinkon0,r:hor25-blinkon0"
o.hidden = true
o.ignorecase = true
o.list = true
o.listchars = "tab:> ,trail:-,nbsp:+"
o.modeline = true
o.modelines = 10
o.mouse = "a"
o.mousefocus = true
o.number = true
o.scrolloff = 3 -- Minimum number of screen lines to keep above and below the cursor
o.shiftwidth = 4 -- Size of an indent
o.showmatch = true -- Show matching parentheses
o.signcolumn = "yes" -- Always show signcolumns
o.smartcase = true
o.smartindent = true -- Insert indents automatically
o.softtabstop = 0
o.splitbelow = true
o.splitright = true
o.swapfile = false
o.tabstop = 4 -- Number of spaces tabs count for
o.termguicolors = true -- True color support
o.title = true
o.titlestring = "%F"
o.updatetime = 100
o.undodir = "/tmp"
o.undofile = true
o.wildignorecase = true
o.wildmode = "longest,list:longest,full"
o.writebackup = false

wo.wrap = false

g.mapleader = LEADER
g.python_host_prog = "~/.pyenv/shims/python2"
g.python3_host_prog = "~/.pyenv/shims/python3"

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
set shortmess+=c

augroup jenkinsfile
    autocmd!
    au BufNewFile,BufRead Jenkinsfile* setf groovy
augroup END

augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=1000}
augroup END

augroup remember_cursor_position
    autocmd!
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\""
augroup END
]],
  false
)
