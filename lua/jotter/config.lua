--- @brief [[
--- Configuration module for jotter.nvim.
--- Manages default settings, user options overrides, and active configuration state.
--- ]]

local M = {}

--- Default configuration options for jotter.nvim.
--- @field width number Floating window width ratio (0.0 to 1.0). Defaults to 0.75.
--- @field height number Floating window height ratio (0.0 to 1.0). Defaults to 0.70.
--- @field filename string Persistent markdown storage filename in stdpath("data"). Defaults to "jotter.md".
--- @field open_mode string Window opening mode ("float" or "split"). Defaults to "float".
--- @field split_side string Split orientation/position ("below", "above", "left", "right"). Defaults to "below".
--- @field keymaps table Keybinding configurations. Defaults to `<leader>n`.
M.defaults = {
	width = 0.75,
	height = 0.70,
	filename = "jotter.md",
	open_mode = "float", -- "float" or "split"
	split_side = "below", -- "below", "above", "left", "right"
	keymaps = {
		toggle = "<leader>n",
	},
}

--- Active configuration options table, merged with user options during setup().
M.options = vim.tbl_deep_extend("force", {}, M.defaults)

--- Sets up jotter configuration by deeply merging user-supplied options with defaults.
--- @param user_opts table|nil User configuration options table overriding defaults.
--- @return table M.options The updated active configuration table.
function M.setup(user_opts)
	M.options = vim.tbl_deep_extend("force", M.defaults, user_opts or {})
	return M.options
end

return M
