local ok, err = pcall(function()
	local languages = {
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
	}
	assert(require("nvim-treesitter").install(languages, { max_jobs = 2 }):wait(180000))
	vim.api.nvim_buf_set_lines(0, 0, -1, false, { "local answer = 42" })
	local trees = vim.treesitter.get_parser(0, "lua"):parse()
	assert(#trees > 0 and not trees[1]:root():has_error(), "Lua parser failed")
	assert(require("blink.cmp.config").fuzzy.implementation == "lua")
	vim.wait(1000)
	assert(vim.v.errmsg == "", vim.v.errmsg)
	assert(#_G.startup_errors == 0, table.concat(_G.startup_errors, "\n"))
end)
if not ok then
	print("FAIL: " .. tostring(err))
	vim.cmd("cquit 1")
end
print("PASS: clean startup, all configured parsers installed, Lua syntax parsed, Lua completion matcher selected")
vim.cmd("qa!")
