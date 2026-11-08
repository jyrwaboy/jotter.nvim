local M = {}

M.defaults = {
	width = 0.75,
	height = 0.70,
	filename = "scratchpad.md",
	keymaps = {
		toggle = "<leader>n",
	},
}

M.options = vim.tbl_deep_extend("force", {}, M.defaults)

--- Sets up jotter configuration by merging user options with defaults.
--- @param user_opts table|nil User configuration options
--- @return table The updated configuration options
function M.setup(user_opts)
	M.options = vim.tbl_deep_extend("force", M.defaults, user_opts or {})
	return M.options
end

return M
