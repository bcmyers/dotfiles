-- Only required if you have packer in your `opt` pack
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(
  function()
    use { 'wbthomason/packer.nvim', opt = true }

    -- use { 'airblade/vim-rooter' }
    use { 'christoomey/vim-tmux-navigator' }
    use { 'ekalinin/Dockerfile.vim' }
    use { 'itchyny/lightline.vim' }
    use { 'itspriddle/vim-shellcheck' }
    -- use { 'junegunn/fzf' }
    -- use { 'junegunn/fzf.vim' }
    use { 'neovim/nvim-lspconfig' }
    use { 'ntpeters/vim-better-whitespace' }
    use { 'nvim-lua/completion-nvim' }
    use {
      'nvim-telescope/telescope.nvim',
      requires = { { 'nvim-lua/plenary.nvim' }, { 'nvim-lua/popup.nvim' } }
    }
    use { 'nvim-treesitter/completion-treesitter ' }
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
    use { 'preservim/nerdtree' }
    use { 'rhysd/vim-clang-format' }
    use { 'tpope/vim-commentary' }
    use { 'Yggdroot/indentLine' }

    -- colorschemes
    use { 'chriskempson/base16-vim' }
    use { 'fcpg/vim-fahrenheit' }
    use { 'gustavo-hms/garbo' }
    use { 'joshdick/onedark.vim' }
    use { 'morhetz/gruvbox' }
    use { 'pineapplegiant/spaceduck' }
    use { 'tomasr/molokai' }
  end
)
