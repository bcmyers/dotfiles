setlocal colorcolumn=80,100
setlocal expandtab
setlocal shiftwidth=2
setlocal tabstop=2
augroup vim
    autocmd!
    autocmd BufWritePost .vimrc source ~/.vimrc
augroup END
