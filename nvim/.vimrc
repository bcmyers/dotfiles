"*****************************************************************************
" Plugins
"*****************************************************************************
call plug#begin(expand('~/.vim/plugged'))

" Plug 'airblade/vim-rooter'
" Plug 'arzg/vim-rust-syntax-ext'
Plug 'itspriddle/vim-shellcheck'
Plug 'bazelbuild/vim-bazel'
Plug 'chriskempson/base16-vim'
Plug 'christoomey/vim-tmux-navigator'
Plug 'ekalinin/Dockerfile.vim'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'google/vim-maktaba'
Plug 'itchyny/lightline.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'machakann/vim-highlightedyank'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'ntpeters/vim-better-whitespace'
Plug 'rhysd/vim-clang-format'
Plug 'scrooloose/nerdtree'
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-commentary'
Plug 'Yggdroot/indentLine'

" TODO
Plug 'tjdevries/colorbuddy.nvim'
Plug 'rhysd/git-messenger.vim'

call plug#end()

"*****************************************************************************
" Neovim defaults
"*****************************************************************************

filetype plugin indent on

if !has('nvim')
    syntax on
    set autoindent
    set autoread
    set background=dark
    set backspace=indent,eol,start
    set belloff=all
    set nocompatible
    set complete-=i
    set cscopeverbose
    set display=lastline
    set encoding=utf-8
    set fillchars=vert:│,fold:·"
    set formatoptions=tcqj
    set nofsync
    set history=10000
    set hlsearch " Highlight search terms
    set incsearch " Show matches as you type
    set langnoremap
    set nolangremap
    set laststatus=2 " 0 = never, 1 = only if there are at least 2 windows, 2 = always
    set listchars="tab:> ,trail:-,nbsp:+"
    set nrformats=bin,hex
    set ruler
    set sessionoptions=blank,buffers,curdir,folds,help,tabpages,winsize
    set showcmd
    set sidescroll=1
    set shortmess=filnxtToOF
    set smarttab
    set nostartofline
    set tabpagemax=50
    set tags=./tags;,tags
    set ttimeoutlen=50
    set ttyfast
    set wildmenu
    set wildoptions=tagfile
    set viminfo=!,'100,<50,s10,h
endif

"*****************************************************************************
" General
"*****************************************************************************

set clipboard=unnamedplus
set noemoji
set expandtab " Insert spaces instead of tabs
set fileencoding=utf-8
set fileencodings=utf-8
set fileformats=unix,dos,mac
set hidden " Enable hidden buffers
set ignorecase
set iskeyword-=_
set list
set modeline
set modelines=10
set mouse=a " Mouse
set shiftwidth=4 " Number of spaces for auto-indenting
set smartcase
set softtabstop=0
set tabstop=4 " Tabs are 4 spaces

" Backups
" 'backup' 'writebackup'	action	~
"    off	     off	    no backup made
"    off	     on		    backup current file, deleted afterwards (default)
"    on	         off	    delete old backup, backup current file
"    on	         on		    delete old backup, backup current file
set nobackup
set nowritebackup

" filetypes
augroup filetypes
    autocmd!
    autocmd BufNewFile,BufRead CMakeLists.txt setlocal filetype=cmake
augroup END

" Remember cursor position
augroup rememberCursorPosition
    autocmd!
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\""
augroup END

" Python
let g:python2_host_prog = '~/.pyenv/shims/python2'
let g:python3_host_prog = '~/.pyenv/shims/python3'

" Shell
if exists('$SHELL')
    set shell=$SHELL
else
    set shell=/bin/sh
endif

" Swap files
set noswapfile

" Syntax highlighting syncing
augroup syntaxHighlightingSyncing
    autocmd!
    au BufEnter * :syntax sync maxlines=2000
augroup END

" Undos
set undofile
set undodir=/tmp

au! BufWritePost $MYVIMRC source %

"*****************************************************************************
" Visual
"*****************************************************************************

" Better display for messages
set cmdheight=2

" set cursorline " Cursor line
set guicursor=a:ver25-blinkon0,r:hor25-blinkon0
set guifont=Monospace\ 10
set guioptions=egmrti
set mousemodel=popup
set number
" set relativenumber
set scrolloff=3 " Minimum number of screen lines to keep above and below the cursor
set showmatch " Show matching parenthesis

" always show signcolumns
set signcolumn=yes

set title
set titleold="Terminal"
set titlestring=%F

" Colors
if !has('nvim') && exists('$TMUX') && &term =~# '^screen'
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif
set termguicolors
" let base16colorspace=256  " Must come before colorscheme declaration
colorscheme base16-default-dark
highlight LineNr guibg=NONE ctermbg=NONE
highlight Normal guibg=NONE ctermbg=NONE
highlight SignColumn guibg=NONE ctermbg=NONE
highlight DiffAdd    guibg=NONE ctermbg=NONE
highlight DiffChange guibg=NONE ctermbg=NONE
highlight DiffDelete guibg=NONE ctermbg=NONE
highlight CocErrorSign ctermfg=Blue guifg=#ff0000
highlight CocWarningSign ctermfg=Brown guifg=#ff922b
highlight CocInfoSign  ctermfg=Yellow guifg=#fab005
highlight CocHintSign  ctermfg=Blue guifg=#15aabf
highlight default link CocErrorVirtualText  CocErrorSign
highlight default link CocWarningVirtualText  CocWarningSign
highlight default link CocInfoVirtualText  CocInfoSign
highlight default link CocHintVirtualText  CocHintSign

" Pum
inoremap <expr> <C-j> pumvisible() ? "\<Down>" : "<C-j>"
inoremap <expr> <C-k> pumvisible() ? "\<Up>" : "<C-k>"
augroup closePum
    autocmd!
    au InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
augroup END
set completeopt-=preview " Disables the preview window feature
set pumheight=15 " Sets the maximum height of the pop-up window

" Visualbell
set noerrorbells visualbell t_vb=

"*****************************************************************************
" Mappings
"*****************************************************************************

" Leader
let mapleader = "\<Space>"

" Better verticle movement for wrapped lines
nnoremap j gj
nnoremap k gk

" Location list toggle
" TODO
noremap <C-e> :call LocationListToggle()<CR>
let g:location_list_is_open = 0
function! LocationListToggle()
    if g:location_list_is_open
        lclose
        let g:location_list_is_open = 0
    else
        lw
        let g:location_list_is_open = 1
    endif
endfunction

" NerdTree
nnoremap <silent> <C-n> :NERDTreeToggle<CR>
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
" nnoremap <silent> <Leader>v :NERDTreeFind<CR>

" Search
nnoremap n nzzzv
nnoremap N Nzzzv
nnoremap <silent> <leader><space> :noh<cr>

" Split windows
" noremap <Leader>h :<C-u>split<CR>
" noremap <Leader>v :<C-u>vsplit<CR>
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l
noremap <C-h> <C-w>h

" Visual mode - move blocks
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
vnoremap H <gv
vnoremap L >gv

" Better tabbing
vnoremap < <gv
vnoremap > >gv

"*****************************************************************************
" coc.nvim
"*****************************************************************************

" if hidden is not set, TextEdit might fail.
set hidden

" Some servers have issues with backup files, see #649
set nobackup
set nowritebackup

" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=100

" don't give |ins-completion-menu| messages.
set shortmess+=c

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <CR> to confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
" Or use `complete_info` if your vim support it, like:
" inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for format selected region
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
" xmap <leader>a  <Plug>(coc-codeaction-selected)
" nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap for do codeAction of current line
" nmap <leader>ac  <Plug>(coc-codeaction)
" Fix autofix problem of current line
" nmap <leader>qf  <Plug>(coc-fix-current)

" Create mappings for function text object, requires document symbols feature of languageserver.
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)

" Use <TAB> for select selections ranges, needs server support, like: coc-tsserver, coc-python
nmap <silent> <TAB> <Plug>(coc-range-select)
xmap <silent> <TAB> <Plug>(coc-range-select)

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')

" Use `:Fold` to fold current buffer
" command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" use `:OR` for organize import of current buffer
" command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add status line support, for integration with other plugin, checkout `:h coc-status`
" set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

let g:coc_disable_startup_warning = 1

"*****************************************************************************
" Other plugins
"*****************************************************************************

" fzf
nnoremap <Leader>f :FZF<cr>
nnoremap <Leader>r :Rg<cr>

set wildmode=list:longest,full
set wildignore+=*.o,*.obj,.git,*.rbc,*.pyc,__pycache__

let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow --glob "!.git/*"'

set grepprg=rg\ --vimgrep

command! -bang -nargs=* Find
    \ call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --hidden --follow --glob "!.git/*" --color "always" '.shellescape(<q-args>).'| tr -d "\017"', 1, <bang>0)

command! -bang -nargs=* Rg
  \ call fzf#vim#grep('rg --column --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>), 1, fzf#vim#with_preview(), <bang>0)

" indentLine
let g:indentLine_enabled = 1

" go
let g:go_version_warning = 0

" lightline
set noshowmode
let g:lightline = {
    \ 'colorscheme': 'wombat',
    \ 'active': {
        \ 'left':  [ [ 'mode', 'paste' ],
        \            [ 'readonly', 'filename', 'modified', ],
        \            [ 'cocstatus', ] ],
        \ 'right': [ [ 'lineinfo' ],
        \            [ 'percent' ],
        \            [ 'fileformat', 'fileencoding', 'filetype', 'charvaluehex' ] ]
    \ },
    \ 'component_function': {
	    \ 'cocstatus': 'coc#status'
	\ },
    \}

" nerdtree
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

" vim-better-whitespace
let g:better_whitespace_enabled=1
let g:show_spaces_that_precede_tabs=1
let g:strip_whitespace_on_save=1
let g:strip_whitelines_at_eof=1

" vim-clang-format
augroup vimClangFormat
    autocmd!
    autocmd FileType c ClangFormatAutoEnable
    autocmd FileType cpp ClangFormatAutoEnable
    autocmd FileType proto ClangFormatAutoEnable
augroup END

" vim-gitgutter
let g:gitgutter_override_sign_column_highlight = 0

" vim-highlightedyank
let g:highlightedyank_highlight_duration = 3000

" vim-javascript
let g:javascript_enable_domhtmlcss = 1

" vim-markdown
let g:markdown_enable_spell_checking = 0
