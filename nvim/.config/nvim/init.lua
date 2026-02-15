--------------------------------------------------------------------------------
-- Pre-plugin globals
--------------------------------------------------------------------------------

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.codeium_disable_bindings = 1

--------------------------------------------------------------------------------
-- Section 1: Bootstrap
--------------------------------------------------------------------------------

vim.pack.add({
	{
		src = "https://github.com/catppuccin/nvim",
		name = "catppuccin",
		version = "0a5de4da015a175f416d6ef1eda84661623e0500",
	}, -- 2026-02-15
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		version = "4d9466677a5ceadef104eaa0fe08d60d91c4e9a7",
	}, -- 2026-02-14
	{
		src = "https://github.com/saghen/blink.cmp",
		version = "cd79f572971c58784ca72551af29af3a63da9168",
	}, -- 2026-02-14
	{
		src = "https://github.com/nvim-telescope/telescope.nvim",
		version = "ad7d9580338354ccc136e5b8f0aa4f880434dcdc",
	}, -- 2026-01-23
	{
		src = "https://github.com/nvim-lua/plenary.nvim",
		version = "b9fd5226c2f76c951fc8ed5923d85e4de065e509",
	}, -- 2025-07-26
	{
		src = "https://github.com/lewis6991/gitsigns.nvim",
		version = "9f3c6dd7868bcc116e9c1c1929ce063b978fa519",
	}, -- 2026-02-13
	{
		src = "https://github.com/stevearc/conform.nvim",
		version = "c2526f1cde528a66e086ab1668e996d162c75f4f",
	}, -- 2026-01-18
	{
		src = "https://github.com/folke/which-key.nvim",
		version = "3aab2147e74890957785941f0c1ad87d0a44c15a",
	}, -- 2025-10-28
	{
		src = "https://github.com/nvim-lualine/lualine.nvim",
		version = "47f91c416daef12db467145e16bed5bbfe00add8",
	}, -- 2025-11-23
	{
		src = "https://github.com/echasnovski/mini.icons",
		version = "68c178e0958d95b3977a771f3445429b1bded985",
	}, -- 2026-02-13
	{
		src = "https://github.com/Exafunction/windsurf.vim",
		version = "3c0a4f8a7be75113a6e19be13b7cc37210d6e26a",
	}, -- 2026-01-22
	{
		src = "https://github.com/folke/snacks.nvim",
		version = "fe7cfe9800a182274d0f868a74b7263b8c0c020b",
	}, -- 2025-11-18
	{
		src = "https://github.com/folke/todo-comments.nvim",
		version = "31e3c38ce9b29781e4422fc0322eb0a21f4e8668",
	}, -- 2025-11-10
	{
		src = "https://github.com/echasnovski/mini.pairs",
		version = "4089aa6ea6423e02e1a8326a7a7a00159f6f5e04",
	}, -- 2026-01-22
	{
		src = "https://github.com/williamboman/mason.nvim",
		version = "44d1e90e1f66e077268191e3ee9d2ac97cc18e65",
	}, -- 2026-01-07
	{
		src = "https://github.com/j-hui/fidget.nvim",
		version = "7fa433a83118a70fe24c1ce88d5f0bd3453c0970",
	}, -- 2026-01-13
	{
		src = "https://github.com/cappyzawa/trim.nvim",
		version = "765360a6f6ac732f4c78c5c694f4b892a55b53ec",
	}, -- 2025-12-30
	{
		src = "https://github.com/saecki/crates.nvim",
		version = "ac9fa498a9edb96dc3056724ff69d5f40b898453",
	}, -- 2025-08-23
}, { load = true })

--------------------------------------------------------------------------------
-- Section 2: Options
--------------------------------------------------------------------------------

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = false

-- Tabs / indentation (defaults; overridden per filetype in after/ftplugin/)
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true -- use spaces for tabs
vim.opt.smartindent = true -- insert indents automatically

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- UI
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = "80,100,120"
vim.opt.cursorline = true
vim.opt.laststatus = 3
vim.opt.showtabline = 0
vim.opt.showmode = false

-- Splits
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Undo
vim.opt.undofile = true

-- Clipboard
vim.opt.clipboard = "unnamedplus"

-- Scroll
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- Cursor (ver25 = thin line, blinkon0 = no blinking)
vim.opt.guicursor = "a:ver25-blinkon0,r:hor25-blinkon0"

-- Visible whitespace
vim.opt.list = true
vim.opt.listchars = {
	extends = ">",
	nbsp = "·",
	precedes = "<",
	space = " ",
	tab = ">·",
	trail = "·",
}

-- Misc
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.wrap = false
vim.opt.mouse = "a"

-- Filetype detection for Starlark/Bazel
vim.filetype.add({
	extension = {
		star = "bzl",
	},
	filename = {
		["BUILD"] = "bzl",
		["BUILD.bazel"] = "bzl",
		["WORKSPACE"] = "bzl",
		["WORKSPACE.bazel"] = "bzl",
		["MODULE.bazel"] = "bzl",
	},
})

--------------------------------------------------------------------------------
-- Section 3: Colorscheme
--------------------------------------------------------------------------------

require("catppuccin").setup({
	flavour = "mocha",
	integrations = {
		gitsigns = true,
		telescope = { enabled = true },
		treesitter = true,
		which_key = true,
		mini = { enabled = true },
		native_lsp = {
			enabled = true,
			underlines = {
				errors = { "undercurl" },
				hints = { "undercurl" },
				warnings = { "undercurl" },
				information = { "undercurl" },
			},
		},
	},
})

vim.cmd.colorscheme("catppuccin")

--------------------------------------------------------------------------------
-- Section 4: Plugin Configs
--------------------------------------------------------------------------------

-- blink.cmp (completion)
require("blink.cmp").setup({
	keymap = { preset = "default" },
	appearance = {
		use_nvim_cmp_as_default = false,
		nerd_font_variant = "mono",
	},
	sources = {
		default = { "lsp", "path", "buffer" },
	},
	signature = { enabled = true },
})

-- Treesitter (highlight + indent are built-in in 0.12; just ensure parsers)
require("nvim-treesitter.install").ensure_installed({
	"bash",
	"go",
	"gomod",
	"gowork",
	"javascript",
	"json",
	"lua",
	"luadoc",
	"markdown",
	"markdown_inline",
	"python",
	"rust",
	"starlark",
	"toml",
	"tsx",
	"typescript",
	"vim",
	"vimdoc",
	"yaml",
})

-- Telescope
require("telescope").setup({
	defaults = {
		layout_strategy = "horizontal",
		layout_config = {
			width = 0.95,
			height = 0.95,
			horizontal = {
				preview_width = 0.50,
				preview_cutoff = 80,
			},
		},
	},
})

-- Gitsigns
require("gitsigns").setup({
	signs = {
		add = { text = "│" },
		change = { text = "│" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
	},
})

-- Conform (formatting)
require("conform").setup({
	formatters_by_ft = {
		bzl = function(bufnr)
			local name = vim.api.nvim_buf_get_name(bufnr)
			if name:match("WORKSPACE") or name:match("WORKSPACE%.bazel") then
				return {}
			end
			return { "buildifier" }
		end,
		star = function(bufnr)
			local name = vim.api.nvim_buf_get_name(bufnr)
			if name:match("WORKSPACE") or name:match("WORKSPACE%.bazel") then
				return {}
			end
			return { "buildifier" }
		end,
		starlark = function(bufnr)
			local name = vim.api.nvim_buf_get_name(bufnr)
			if name:match("WORKSPACE") or name:match("WORKSPACE%.bazel") then
				return {}
			end
			return { "buildifier" }
		end,
		lua = { "stylua" },
		go = { "goimports", "gofmt" },
		rust = { "rustfmt" },
		typescript = { "prettier" },
		javascript = { "prettier" },
		json = { "prettier" },
		yaml = { "prettier" },
	},
	formatters = {
		stylua = {
			prepend_args = { "--column-width", "80" },
		},
		buildifier = {
			command = "buildifier",
			args = { "-type=auto" },
		},
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_format = "fallback",
	},
})

-- Which-key
require("which-key").setup({
	delay = 300,
})

-- Lualine
-- Show file path relative to git root (e.g. "lua/plugins/init.lua"),
-- falls back to path relative to cwd if not in a git repo.
local function git_relative_path()
	local filepath = vim.fn.expand("%:p")
	if filepath == "" then
		return ""
	end
	local root = vim.fs.root(0, ".git")
	if root then
		return filepath:sub(#root + 2)
	end
	return vim.fn.expand("%:.")
end

---@diagnostic disable-next-line: undefined-field
require("lualine").setup({
	options = {
		theme = "auto",
		globalstatus = true,
		disabled_filetypes = { statusline = { "snacks_dashboard" } },
		component_separators = "",
		section_separators = "",
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = {},
		lualine_c = { git_relative_path },
		lualine_x = { "diagnostics" },
		lualine_y = { "location" },
		lualine_z = {},
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { git_relative_path },
		lualine_x = {},
		lualine_y = {},
		lualine_z = {},
	},
})

-- Mini.icons
require("mini.icons").setup()

-- Snacks (dashboard + notifications + explorer)
require("snacks").setup({
	dashboard = { enabled = false },
	notifier = { enabled = true },
	progress = { enabled = true },
	explorer = { enabled = true },
	picker = {
		sources = {
			explorer = {
				hidden = true,
			},
		},
	},
})

-- Fidget (LSP progress indicator)
require("fidget").setup()

-- Todo-comments
require("todo-comments").setup()

-- Mini.pairs
require("mini.pairs").setup()

-- Mason
require("mason").setup({
	ensure_installed = { "starpls", "buildifier" },
})

-- Trim (trailing whitespace)
require("trim").setup({
	trim_on_write = true,
	trim_trailing = true,
	trim_first_line = true,
	trim_last_line = true,
})

-- Crates (Cargo.toml crate version info)
require("crates").setup()

--------------------------------------------------------------------------------
-- Section 5: LSP
--------------------------------------------------------------------------------

-- Global LSP defaults
vim.lsp.config("*", {
	root_markers = { ".git" },
})

-- lua_ls
vim.lsp.config("lua_ls", {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = { ".luarc.json", ".luarc.jsonc", ".stylua.toml", ".git" },
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			diagnostics = { globals = { "vim" } },
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false,
			},
			telemetry = { enable = false },
		},
	},
})

-- starpls (Starlark/Bazel)
vim.lsp.config("starpls", {
	cmd = { "starpls" },
	filetypes = { "bzl", "star", "starlark" },
	root_markers = { "MODULE.bazel", "WORKSPACE", "WORKSPACE.bazel", ".git" },
})

-- gopls (via dd-gopls wrapper)
vim.lsp.config("gopls", {
	cmd = { "dd-gopls" },
	cmd_env = { GOPLS_DISABLE_MODULE_LOADS = "1" },
	filetypes = { "go", "gomod", "gowork", "gotmpl" },
	root_markers = { "go.mod", "go.work", ".git" },
	settings = {
		gopls = {
			analyses = {
				unusedparams = true,
			},
			staticcheck = true,
		},
	},
})

-- rust_analyzer
vim.lsp.config("rust_analyzer", {
	cmd = { "rust-analyzer" },
	filetypes = { "rust" },
	root_markers = { "rust-project.json", ".git" },
	settings = {
		["rust-analyzer"] = {
			check = { command = "clippy" },
		},
	},
})

-- ts_ls (TypeScript)
vim.lsp.config("ts_ls", {
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = {
		"typescript",
		"typescriptreact",
		"javascript",
		"javascriptreact",
	},
	root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
})

-- Enable all LSP servers
vim.lsp.enable({ "lua_ls", "starpls", "gopls", "rust_analyzer", "ts_ls" })

-- Diagnostics
vim.diagnostic.config({
	virtual_text = true,
	virtual_lines = false,
	signs = true,
	underline = false,
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded",
		source = true,
	},
	jump = {
		wrap = true,
		float = {
			border = "rounded",
		},
	},
})

--------------------------------------------------------------------------------
-- Section 6: Keymaps
--------------------------------------------------------------------------------

local map = vim.keymap.set

-- Clear search highlights
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Explorer
map("n", "<leader>E", function()
	Snacks.explorer()
end, { desc = "File explorer" })

-- Telescope
local builtin = require("telescope.builtin")
map("n", "<leader>ff", function()
	builtin.find_files({
		hidden = true,
		previewer = true,
	})
end, { desc = "Find files" })
map("n", "<leader>fd", function()
	builtin.diagnostics({
		bufnr = 0,
		line_width = "full",
	})
end, { desc = "Diagnostics (current file)" })
map("n", "<leader>fD", builtin.diagnostics, { desc = "Diagnostics" })
map("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
map("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
map("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })

-- Diagnostics
map("n", "[d", function()
	vim.diagnostic.jump({ count = -1 })
end, { desc = "Previous diagnostic" })
map("n", "]d", function()
	vim.diagnostic.jump({ count = 1 })
end, { desc = "Next diagnostic" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Diagnostic float" })

-- Formatting
map({ "n", "v" }, "<leader>cf", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format" })

-- Windsurf (AI completion)
map("i", "<C-u>", function()
	return vim.fn["codeium#Accept"]()
end, { expr = true, silent = true, desc = "Accept AI suggestion" })
map("i", "<C-]>", function()
	return vim.fn["codeium#CycleCompletions"](1)
end, { expr = true, silent = true, desc = "Cycle AI suggestions" })

--------------------------------------------------------------------------------
-- Section 7: Autocommands
--------------------------------------------------------------------------------

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- LSP attach keymaps
autocmd("LspAttach", {
	group = augroup("lsp-attach", { clear = true }),
	callback = function(event)
		local function opts(desc)
			return { buffer = event.buf, desc = desc }
		end

		map("n", "gc", vim.lsp.buf.incoming_calls, opts("Incoming calls"))
		map("n", "gD", vim.lsp.buf.declaration, opts("Go to declaration"))
		map("n", "gd", vim.lsp.buf.definition, opts("Go to definition"))
		map("n", "gi", vim.lsp.buf.implementation, opts("Go to implementation"))
		map("n", "gr", vim.lsp.buf.references, opts("References"))
		map("n", "K", vim.lsp.buf.hover, opts("Hover"))
		map("n", "<leader>ca", vim.lsp.buf.code_action, opts("Code action"))
		map("n", "<leader>rn", vim.lsp.buf.rename, opts("Rename"))
		map(
			"n",
			"<leader>D",
			vim.lsp.buf.type_definition,
			opts("Type definition")
		)
	end,
})

-- Highlight on yank
autocmd("TextYankPost", {
	group = augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})
