-- Only required if you have packer configured as `opt`
vim.cmd("packadd packer.nvim")

require("packer").startup(
  function()
    -- packer
    use "wbthomason/packer.nvim"

    -- autopairs
    use "windwp/nvim-autopairs"

    -- better-whitespace
    use "ntpeters/vim-better-whitespace"

    -- commentary
    use "tpope/vim-commentary"

    -- compe
    use {"hrsh7th/nvim-compe", requires = {"hrsh7th/vim-vsnip"}}

    -- formatter
    use "mhartington/formatter.nvim"

    -- gitsigns
    use {"lewis6991/gitsigns.nvim", requires = {"nvim-lua/plenary.nvim"}}

    -- indentLine
    use "Yggdroot/indentLine"

    -- lightline
    use "itchyny/lightline.vim"

    -- lspconfig
    use "neovim/nvim-lspconfig"

    -- lsp-signature
    use "ray-x/lsp_signature.nvim"

    -- lsp-utils
    use {"RishabhRD/nvim-lsputils", requires = {"RishabhRD/popfix"}}

    -- popup
    use {"nvim-lua/popup.nvim", requires = {"nvim-lua/plenary.nvim"}}

    -- reload
    use "famiu/nvim-reload"

    -- rust-tools
    use "simrat39/rust-tools.nvim"

    -- telescope
    use {"nvim-telescope/telescope.nvim", requires = {"nvim-lua/plenary.nvim", "nvim-lua/popup.nvim"}}

    -- tmux-navigator
    use "christoomey/vim-tmux-navigator"

    -- tree
    use {"kyazdani42/nvim-tree.lua", requires = {"kyazdani42/nvim-web-devicons"}}

    -- treesitter
    use {"nvim-treesitter/nvim-treesitter", run = ":TSUpdate"}

    -- colorschemes
    use "chriskempson/base16-vim"
    use "fcpg/vim-fahrenheit"
    use "gustavo-hms/garbo"
    use "morhetz/gruvbox"
    use "pineapplegiant/spaceduck"
    use "tomasr/molokai"
  end
)

require("core")
require("colors")

require("my-lspconfig")

require("my-autopairs")
require("my-better-whitespace")
require("my-commentary")
require("my-compe")
require("my-formatter")
require("my-gitsigns")
require("my-indentline")
require("my-lightline")
require("my-lsp-signature")
require("my-lsp-utils")
require("my-rust-tools")
require("my-telescope")
require("my-tmux-navigator")
require("my-tree")
require("my-treesitter")
