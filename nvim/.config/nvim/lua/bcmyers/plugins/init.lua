local download_packer = function()
  if vim.fn.input("Download Packer? (y for yes)" ~= "y") then
    return
  end
  local directory = string.format("%s/site/pack/packer/start/", vim.fn.stdpath "data")
  vim.fn.mkdir(directory, "p")
  local out = vim.fn.system(
    string.format("git clone %s %s", "https://github.com/wbthomason/packer.nvim", directory .. "/packer.nvim")
  )
  print(out)
  print("Downloading packer.nvim...")
  print("( You'll need to restart now )")
end

if not pcall(require, "packer") then
  download_packer()
end

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
    use { "hrsh7th/cmp-nvim-lua" }
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

    -- fidget
    use "j-hui/fidget.nvim"

    -- formatter
    use "mhartington/formatter.nvim"

    --- just
    use "NoahTheDuke/vim-just"

    -- lsp-config
    use "neovim/nvim-lspconfig"

    -- lsp-signature
    use "ray-x/lsp_signature.nvim"

    -- lsp-utils
    use {"RishabhRD/nvim-lsputils", requires = {"RishabhRD/popfix"}}

    -- lualine
    use {"hoob3rt/lualine.nvim", requires = {"kyazdani42/nvim-web-devicons", opt = true}}

    -- markdown-preview
    use {"davidgranstrom/nvim-markdown-preview"}

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

    -- colorschemes
    use "chriskempson/base16-vim"
    -- use "fcpg/vim-fahrenheit"
    -- use "gustavo-hms/garbo"
    -- use "morhetz/gruvbox"
    -- use "pineapplegiant/spaceduck"
    -- use "tomasr/molokai"

    -- bcmyers
    use "/Users/bcmyers/lib/nvim/bcmyers-git"

    -- disabled

    -- gitsigns
    -- use {"lewis6991/gitsigns.nvim", requires = {"nvim-lua/plenary.nvim"}}

    -- lspsaga
    -- use "glepnir/lspsaga.nvim"

    -- nerdtree
    -- use {"preservim/nerdtree"}

    -- nvim-startup
    -- use {"henriquehbr/nvim-startup.lua"}

    -- nvim-tree
    -- use {"kyazdani42/nvim-tree.lua", requires = {"kyazdani42/nvim-web-devicons"}}
  end
)

require("bcmyers.plugins.lsp-config")

require("bcmyers.plugins.autopairs")
require("bcmyers.plugins.better-whitespace")
require("bcmyers.plugins.cmp")
require("bcmyers.plugins.fidget")
require("bcmyers.plugins.formatter")
require("bcmyers.plugins.lsp-utils")
require("bcmyers.plugins.lualine")
-- require("bcmyers.plugins.nerdtree")
require("bcmyers.plugins.telescope")
require("bcmyers.plugins.treesitter")
