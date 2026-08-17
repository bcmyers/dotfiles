-- Personal-only hosted AI completion. This file is appended to init.lua by
-- users/bcmyers/neovim.nix and is deliberately absent from the work profile.
vim.g.codeium_disable_bindings = 1

vim.pack.add({
	{
		src = "https://github.com/Exafunction/windsurf.vim",
		version = "3c0a4f8a7be75113a6e19be13b7cc37210d6e26a",
	}, -- 2026-01-22
}, { load = true })

vim.keymap.set("i", "<C-u>", function()
	return vim.fn["codeium#Accept"]()
end, { expr = true, silent = true, desc = "Accept AI suggestion" })

vim.keymap.set("i", "<C-]>", function()
	return vim.fn["codeium#CycleCompletions"](1)
end, { expr = true, silent = true, desc = "Cycle AI suggestions" })
