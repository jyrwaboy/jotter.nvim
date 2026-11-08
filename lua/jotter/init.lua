local config = require("jotter.config")
local state = require("jotter.state")
local ui = require("jotter.ui")

local M = {}

--- Opens the scratchpad in a centered floating window.
--- @param origin_override number|nil Optional buffer handle to restore on close
function M.open(origin_override)
	ui.open(origin_override)
end

--- Closes the scratchpad floating window.
function M.close()
	ui.close()
end

--- Toggles the scratchpad floating window open or closed.
function M.toggle()
	if state.is_valid_win(state.float_win) then
		ui.close()
		return
	end

	local pre_buf = vim.api.nvim_get_current_buf()
	ui.open(pre_buf)
end

--- Initializes jotter.nvim with user options, keymaps, commands, and autocommands.
--- @param user_opts table|nil User configuration options
function M.setup(user_opts)
	config.setup(user_opts)

	local toggle_key = config.options.keymaps and config.options.keymaps.toggle or "<leader>n"
	vim.keymap.set("n", toggle_key, M.toggle, { silent = true, desc = "Toggle Jotter" })

	vim.api.nvim_create_user_command("Jotter", function()
		M.toggle()
	end, { desc = "Toggle jotter" })
	
	vim.api.nvim_create_user_command("JotterClose", function()
		M.close()
	end, { desc = "Close jotter" })

	vim.api.nvim_create_autocmd("VimLeavePre", {
		callback = function()
			ui.save_to_disk()
		end,
	})

	vim.api.nvim_create_autocmd("WinClosed", {
		callback = function(args)
			if tonumber(args.match) == state.float_win then
				state.reset()
			end
		end,
	})
end

return M
