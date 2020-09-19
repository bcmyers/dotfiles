local leader = ' '
local width = 80

vim.api.nvim_exec([[
filetype plugin indent on
syntax on
]], false)

vim.o.autoread          = true
vim.o.belloff           = 'all'
vim.o.clipboard         = 'unnamedplus'
vim.o.cmdheight         = 2
vim.o.emoji             = false
vim.o.formatoptions     = 'cjnqr'
vim.o.guicursor         = 'a:ver25-blinkon0,r:hor25-blinkon0'
vim.o.hidden            = true
vim.o.ignorecase        = true
vim.o.listchars         = 'tab:> ,trail:-,nbsp:+'
vim.o.modeline          = true
vim.o.modelines         = 10
vim.o.mouse             = 'a'
vim.o.mousefocus        = true
vim.o.scrolloff         = 3    -- Minimum number of screen lines to keep above and below the cursor
vim.o.showmatch         = true -- Show matching parentheses
vim.o.smartcase         = true
vim.o.splitbelow        = true
vim.o.splitright        = true
vim.o.termguicolors     = true
vim.o.title             = true
vim.o.titlestring       = '%F'
vim.o.updatetime        = 100
vim.o.undodir           = '/tmp'
vim.o.undofile          = true
vim.o.wildignorecase    = true
vim.o.wildmode          = 'longest,list:longest,full'

vim.wo.colorcolumn      = '80,120'
vim.wo.list             = true
vim.wo.number           = true
vim.wo.signcolumn       = 'yes' -- Always show signcolumns

vim.g.mapleader = leader
vim.g.python_host_prog  = '~/.pyenv/shims/python2'
vim.g.python3_host_prog = '~/.pyenv/shims/python3'

-- backup writebackup
-- ------ -----------
-- false  false       no backup made
-- false  true        backup current file, deleted afterwards (default)
-- true   false       delete old backup, backup current file
-- true   true        delete old backup, backup current file
vim.o.backup            = false
vim.o.writebackup       = false

-- Modelines
-- vim.bo.modeline         = true
vim.o.modelines         = 10

-- Wrapping
vim.o.scrolloff         = 4 -- Minimum number of lines to keep above and below the cursor
vim.o.sidescrolloff     = 4 -- Minimum number of columns to keep to the left and right of the cursor
vim.wo.wrap             = false

-------------------------------------------------------------------------------

-- Broken lua
vim.api.nvim_exec([[
set autoindent
set expandtab
set iskeyword="@,48-57,192-255"
set modeline
set softtabstop=0
set shiftwidth=4
set smartindent
set noswapfile
set tabstop=4

augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=1000}
augroup END

augroup remember_cursor_position
    autocmd!
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\""
augroup END

augroup sync_syntax_highlighting
    autocmd!
    au BufEnter * :syntax sync maxlines=2000
augroup END

if exists('+termguicolors')
    let &t_8f = "\<Esc>[38;2;o%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif
]], false)

-- Better search defaults
vim.api.nvim_set_keymap('n', 'n', 'nzzzv', { noremap = true })
vim.api.nvim_set_keymap('n', 'N', 'Nzzzv', { noremap = true })

-- LSP (TODO: This is incomplete)
vim.api.nvim_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', 'K',  '<cmd>lua vim.lsp.buf.hover()<CR>', { noremap = true })

-------------------------------------------------------------------------------

-- completion (recommended settings) (TODO: This is incomplete)
vim.api.nvim_exec([[
" Use <Tab> and <S-Tab> to navigate through popup menu
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Set completeopt to have a better completion experience
set completeopt=menuone,noinsert,noselect

" Avoid showing message extra message when using completion
set shortmess+=c
]], false)

-- fzf
-- vim.api.nvim_set_keymap('n', '<C-p>', ':FZF<CR>', { noremap = true })
-- vim.api.nvim_set_keymap('n', '<C-r>', ':Rg<CR>', { noremap = true })
-- vim.api.nvim_exec([[
-- let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow --glob "!.git/*"'
-- ]], false)

-- indentLine
vim.g.indentLine_enabled = 1

-- lightline (TODO: This is incomplete)
vim.g.lightline = { colorscheme = 'wombat' }

-- nerd tree (TODO: This is incomplete)
vim.api.nvim_set_keymap('n', '<C-n>', ':NERDTreeToggle<CR>', { noremap = true, silent = true })
vim.g.NERDTreeMinimalUI = 1
vim.g.NERDTreeDirArrows = 1
vim.api.nvim_exec([[
let g:NERDTreeChDirMode=2
let g:NERDTreeIgnore=['\.rbc$', '\~$', '\.pyc$', '\.db$', '\.sqlite$', '__pycache__']
let g:NERDTreeShowBookmarks=1
let g:NERDTreeShowHidden=1
let g:NERDTreeSortOrder=['^__\.py$', '\/$', '*', '\.swp$', '\.bak$', '\~$']
let g:NERDTreeWinSize = 25
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.pyc,*.db,*.sqlite
augroup closeNERDTree
    autocmd!
    " If NERDTree is open when the last buffer is closed, close it and quit
    au bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
augroup END
]], false)

-- telescope (TODO: This is incomplete)
vim.api.nvim_set_keymap('n', '<C-p>', '<cmd>Telescope find_files<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-g>', '<cmd>Telescope live_grep<CR>', { noremap = true })

-- treesitter
require'nvim-treesitter.configs'.setup {
  ensure_installed = "maintained",
  highlight = { enable = true },
  incremental_selection = { enable = true },
  indent = { enable = true },
}

-- completion-treesitter
-- vim.api.nvim_exec([[
-- let g:completion_chain_complete_list = {
--             \'default' : {
--             \   'default' : [
--             \       {'complete_items' : ['lsp', 'snippet']},
--             \       {'mode' : 'file'}
--             \   ],
--             \   'comment' : [],
--             \   'string' : []
--             \   },
--             \'vim' : [
--             \   {'complete_items': ['snippet']},
--             \   {'mode' : 'cmd'}
--             \   ],
--             \'c' : [
--             \   {'complete_items': ['ts']}
--             \   ],
--             \'python' : [
--             \   {'complete_items': ['ts']}
--             \   ],
--             \'lua' : [
--             \   {'complete_items': ['ts']}
--             \   ],
--             \}
-- autocmd BufEnter * lua require'completion'.on_attach()
-- ]], false)

-- vim better whitespace
vim.api.nvim_exec([[
let g:better_whitespace_enabled = 1
let g:strip_whitespace_on_save = 1

let g:show_spaces_that_precede_tabs = 1
let g:strip_whitelines_at_eof = 1
]], false)

-------------------------------------------------------------------------------

local lspconfig = require('lspconfig')
local on_attach = require('completion').on_attach

lspconfig.bashls.setup{
    on_attach=on_attach,
}

lspconfig.dockerls.setup{
    on_attach=on_attach
}

lspconfig.rust_analyzer.setup{
    on_attach=on_attach,
    settings = {
        ['rust-analyzer'] = {
            cargo = { allFeatures = true, autoReload = true },
            checkOnSave = {
                enable=true, command = "clippy",
            },
        }
    }
}

-------------------------------------------------------------------------------

function random_colorscheme()
    local colorschemes = {
        -- light
        -- 'base16-google-light',
        -- 'base16-material-lighter',
        'base16-cupertino',
        -- dark
        -- 'base16-greenscreen',
        -- 'base16-default-dark',
        -- 'base16-atelier-forest',
        -- 'base16-darktooth',
        -- 'base16-isotope',
        -- 'fahrenheit',
        -- 'garbo',
        -- 'gruvbox',
        -- 'molokai',
        -- 'onedark',

        -- Katie likes these
        -- 'base16-outrun-dark',
        -- 'spaceduck',
    }
    math.randomseed(os.time())
    return colorschemes[ math.random( #colorschemes ) ]
end

local colorscheme = random_colorscheme()
print(colorscheme)
vim.api.nvim_command('let base16colorspace=256')
vim.api.nvim_command('colorscheme '..colorscheme)
