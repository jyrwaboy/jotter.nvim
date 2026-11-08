--- @brief [[
--- Main entry point for jotter.nvim.
--- Exposes setup, toggle, open, and close functions, user commands (`:Jotter`, `:JotterSplit`, `:JotterFloat`, `:JotterClip`, `:JotterClose`),
--- and auto-saving/cleanup autocommands.
--- ]]

local config = require("jotter.config")
local state = require("jotter.state")
local ui = require("jotter.ui")

local M = {}

--- Opens the jotter window.
--- @param origin_override number|nil Optional buffer handle to restore on close.
--- @param mode_override string|nil Optional mode override ("float" or "split").
--- @param filename_override string|nil Optional filename override.
--- @param title_override string|nil Optional title override.
--- @return nil
function M.open(origin_override, mode_override, filename_override, title_override)
	ui.open(origin_override, mode_override, filename_override, title_override)
end

--- Closes the jotter window and restores the origin window.
--- @return nil
function M.close()
	ui.close()
end

--- Toggles the jotter window open or closed.
--- @param mode_override string|nil Optional mode override ("float" or "split").
--- @param filename_override string|nil Optional filename override.
--- @param title_override string|nil Optional title override.
--- @return nil
function M.toggle(mode_override, filename_override, title_override)
	local target_filename = filename_override or config.options.filename or "jotter.md"

	if state.is_valid_win(state.float_win) then
		local current_buf_name = state.is_valid_buf(state.float_buf) and vim.api.nvim_buf_get_name(state.float_buf) or ""
		local target_path = vim.fn.stdpath("data") .. "/" .. target_filename
		local current_is_float = vim.api.nvim_win_get_config(state.float_win).relative ~= ""
		local target_mode = mode_override or config.options.open_mode or "float"
		local target_is_float = (target_mode == "float")

		if current_buf_name == target_path and (current_is_float == target_is_float) then
			ui.close()
			return
		end
	end

	local pre_buf = vim.api.nvim_get_current_buf()
	ui.open(pre_buf, mode_override, filename_override, title_override)
end

--- Initializes jotter.nvim with user options, keymaps, commands, and autocommands.
--- @param user_opts table|nil User configuration options table.
--- @return nil
function M.setup(user_opts)
	config.setup(user_opts)

	local keymaps = config.options.keymaps or {}

	if keymaps.toggle then
		vim.keymap.set("n", keymaps.toggle, function()
			M.toggle()
		end, { silent = true, desc = "Toggle Jotter" })
	end

	if keymaps.split then
		vim.keymap.set("n", keymaps.split, function()
			M.toggle("split")
		end, { silent = true, desc = "Toggle Jotter Split" })
	end

	if keymaps.float then
		vim.keymap.set("n", keymaps.float, function()
			M.toggle("float")
		end, { silent = true, desc = "Toggle Jotter Float" })
	end

	if keymaps.clip then
		vim.keymap.set("n", keymaps.clip, function()
			M.toggle(nil, config.options.clip_filename, " Jotter Clipboard ")
		end, { silent = true, desc = "Toggle Jotter Clipboard History" })
	end

	vim.api.nvim_create_user_command("Jotter", function()
		M.toggle()
	end, { desc = "Toggle jotter" })

	vim.api.nvim_create_user_command("JotterSplit", function()
		M.toggle("split")
	end, { desc = "Toggle/switch jotter to split view" })

	vim.api.nvim_create_user_command("JotterFloat", function()
		M.toggle("float")
	end, { desc = "Toggle/switch jotter to floating window" })

	vim.api.nvim_create_user_command("JotterClip", function()
		M.toggle(nil, config.options.clip_filename, " Jotter Clipboard ")
	end, { desc = "Open clipboard history jotter tab" })
	
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
