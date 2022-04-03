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

    -- cmp
    use { "hrsh7th/nvim-cmp" }
    use { 'hrsh7th/cmp-buffer' }
    use { 'hrsh7th/cmp-cmdline'}
    use { "hrsh7th/cmp-nvim-lsp" }
    use { "hrsh7th/cmp-path" }
    use { "hrsh7th/cmp-vsnip" }
    use { "hrsh7th/vim-vsnip" }
    use { "onsails/lspkind-nvim" }

    -- crates
    use {
        'Saecki/crates.nvim',
        event = { "BufRead Cargo.toml" },
        requires = { { 'nvim-lua/plenary.nvim' } },
        config = function()
            require('crates').setup()
        end,
    }

    -- formatter
    use "mhartington/formatter.nvim"

    -- gitsigns
    -- use {"lewis6991/gitsigns.nvim", requires = {"nvim-lua/plenary.nvim"}}

    -- indentLine
    use "Yggdroot/indentLine"

    -- lightline
    -- use "itchyny/lightline.vim"

    -- lspconfig
    use "neovim/nvim-lspconfig"

    -- lspsaga
    -- use "glepnir/lspsaga.nvim"

    -- lsp-signature
    use "ray-x/lsp_signature.nvim"

    -- lsp-utils
    use {"RishabhRD/nvim-lsputils", requires = {"RishabhRD/popfix"}}

    -- lualine
    use {"hoob3rt/lualine.nvim", requires = {"kyazdani42/nvim-web-devicons", opt = true}}
    use {"arkav/lualine-lsp-progress"}

    -- nerdtree
    -- use {"preservim/nerdtree"}

    -- nvim-startup
    -- use {"henriquehbr/nvim-startup.lua"}

    -- nvim-tree
    -- use {"kyazdani42/nvim-tree.lua", requires = {"kyazdani42/nvim-web-devicons"}}

    -- popup
    use {"nvim-lua/popup.nvim", requires = {"nvim-lua/plenary.nvim"}}

    -- reload
    use "famiu/nvim-reload"

    -- rust-tools
    use "simrat39/rust-tools.nvim"

    -- telescope
    use {"nvim-telescope/telescope.nvim", requires = {"nvim-lua/plenary.nvim", "nvim-lua/popup.nvim"}}
    use {"nvim-telescope/telescope-file-browser.nvim"}
    use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
    use {"AckslD/nvim-neoclip.lua", requires = {'tami5/sqlite.lua'}}
    use {"jvgrootveld/telescope-zoxide"}
    use {"rcarriga/nvim-notify"}

    -- tmux-navigator
    use "christoomey/vim-tmux-navigator"

    -- treesitter
    use {"nvim-treesitter/nvim-treesitter", run = ":TSUpdate"}

    --- vim-just
    use "NoahTheDuke/vim-just"

    -- colorschemes
    use "chriskempson/base16-vim"
    -- use "fcpg/vim-fahrenheit"
    -- use "gustavo-hms/garbo"
    -- use "morhetz/gruvbox"
    -- use "pineapplegiant/spaceduck"
    -- use "tomasr/molokai"

    use "/Users/bcmyers/lib/nvim/bcmyers-git"
  end
)

require("03-plugins.lspconfig")

require("03-plugins.autopairs")
require("03-plugins.better-whitespace")
require("03-plugins.commentary")
require("03-plugins.cmp")
require("03-plugins.formatter")
-- require("03-plugins.gitsigns")
require("03-plugins.indentline")
-- require("03-plugins.lsp-saga")
require("03-plugins.lsp-signature")
require("03-plugins.lsp-utils")
require("03-plugins.lualine")
-- require("03-plugins.nerdtree")
-- require("03-plugins.nvim-tree")
require("03-plugins.rust-tools")
require("03-plugins.telescope")
require("03-plugins.tmux-navigator")
require("03-plugins.treesitter")
