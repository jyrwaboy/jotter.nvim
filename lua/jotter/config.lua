--- @brief [[
--- Configuration module for jotter.nvim.
--- Manages default settings, user options overrides, and active configuration state.
--- ]]

local M = {}

--- Default configuration options for jotter.nvim.
--- @field width number Floating window width ratio (0.0 to 1.0) of editor columns. Defaults to 0.75.
--- @field height number Floating window height ratio (0.0 to 1.0) of editor lines. Defaults to 0.70.
--- @field filename string Persistent markdown storage filename in stdpath("data"). Defaults to "jotter.md".
--- @field keymaps table Keybinding configurations (e.g. toggle key). Defaults to `<leader>n`.
M.defaults = {
	width = 0.75,
	height = 0.70,
	filename = "jotter.md",
	keymaps = {
		toggle = "<leader>n",
	},
}

--- Active configuration options table, merged with user options during setup().
M.options = vim.tbl_deep_extend("force", {}, M.defaults)

--- Sets up jotter configuration by deeply merging user-supplied options with defaults.
--- @param user_opts table|nil User configuration options table overriding defaults.
--- @return table M.options The updated active configuration table.
--- @example
--- require("jotter.config").setup({ width = 0.8, filename = "notes.md" })
function M.setup(user_opts)
	M.options = vim.tbl_deep_extend("force", M.defaults, user_opts or {})
	return M.options
end

return M
