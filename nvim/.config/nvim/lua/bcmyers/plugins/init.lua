local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system(
    {
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable", -- latest stable release
      lazypath
    }
  )
end

vim.opt.rtp:prepend(lazypath)

local plugins = {
  -- used by a lot of other plugins
  "kyazdani42/nvim-web-devicons",
  "nvim-lua/plenary.nvim",
  --
  "cappyzawa/trim.nvim",
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  "chriskempson/base16-vim",
  {"google/vim-jsonnet", ft="jsonnet"},
  "hoob3rt/lualine.nvim",
  {"j-hui/fidget.nvim", tag = "legacy"},
  "jay-babu/mason-null-ls.nvim",
  "jose-elias-alvarez/null-ls.nvim",
  "kyazdani42/nvim-tree.lua",
  "mfussenegger/nvim-dap",
  "neovim/nvim-lspconfig",
  {"NoahTheDuke/vim-just", ft="just"},
  "numToStr/Comment.nvim",
  {"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"},
  {"saecki/crates.nvim", ft="toml"},
  "simrat39/rust-tools.nvim",
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate" -- :MasonUpdate updates registry contents
  },
  "williamboman/mason-lspconfig.nvim",
  "windwp/nvim-autopairs",
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter"
  },
  "zbirenbaum/copilot-cmp",
  --- not done
  "mfussenegger/nvim-dap",
  -- {
  --   "folke/which-key.nvim",
  --   event = "VeryLazy",
  --   init = function()
  --     vim.o.timeout = true
  --     vim.o.timeoutlen = 300
  --   end,
  --   opts = {}
  -- },

  -- cmp
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-cmdline",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-nvim-lua",
  "hrsh7th/cmp-path",
  -- "hrsh7th/cmp-vsnip",
  -- "hrsh7th/vim-vsnip",
  "onsails/lspkind-nvim",

  -- "mhartington/formatter.nvim",


  -- "ray-x/lsp_signature.nvim",

  "RishabhRD/nvim-lsputils",

  -- "davidgranstrom/nvim-markdown-preview",

  -- "rcarriga/nvim-dap-ui",
  -- "theHamsta/nvim-dap-virtual-text",

  "RishabhRD/popfix",


  {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },
  "nvim-telescope/telescope-dap.nvim",
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release',
  },
  -- {
  --   "AckslD/nvim-neoclip.lua",
  --   dependencies = {"tami5/sqlite.lua"}
  -- },
  -- "jvgrootveld/telescope-zoxide",
  "nvim-telescope/telescope-ui-select.nvim",

  -- "christoomey/vim-tmux-navigator",

  "lewis6991/gitsigns.nvim",

  -- "glepnir/lspsaga.nvim"
}

require("lazy").setup(plugins, {})
