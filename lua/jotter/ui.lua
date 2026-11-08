--- @brief [[
--- UI and window management module for jotter.nvim.
--- Handles opening/closing floating or split windows, buffer initialization,
--- render-markdown integration, and buffer-local close keymaps.
--- ]]

local config = require("jotter.config")
local state = require("jotter.state")

local M = {}

local function scratchpad_path()
	local filename = config.options.filename or "jotter.md"
	return vim.fn.stdpath("data") .. "/" .. filename
end

local function ensure_file()
	local p = scratchpad_path()
	if vim.fn.filereadable(p) == 0 then
		local dir = vim.fn.fnamemodify(p, ":h")
		vim.fn.mkdir(dir, "p")
		local fd = io.open(p, "w")
		if fd then
			fd:write("# Jotter\n\n")
			fd:close()
		end
	end
	return p
end

local function save_to_disk()
	if state.is_valid_buf(state.float_buf) then
		vim.api.nvim_buf_call(state.float_buf, function()
			if vim.bo.modified then
				vim.cmd("silent update!")
			end
		end)
	end
end

M.save_to_disk = save_to_disk

--- Opens jotter in either a floating window or a window split based on mode_override or config.
--- If already open in a different mode (e.g., float vs split), closes the current window and re-opens in the new mode.
--- @param origin_override number|nil Optional buffer handle to restore on close.
--- @param mode_override string|nil Optional mode override ("float" or "split").
function M.open(origin_override, mode_override)
	local path = ensure_file()
	local mode = mode_override or config.options.open_mode or "float"

	if not state.is_valid_buf(state.float_buf) then
		state.float_buf = vim.fn.bufadd(path)
		vim.api.nvim_buf_set_name(state.float_buf, path)
	end

	if not vim.api.nvim_buf_is_loaded(state.float_buf) then
		vim.fn.bufload(state.float_buf)
	end

	-- If already open, check if we need to switch mode (e.g. from float to split or vice versa)
	if state.is_valid_win(state.float_win) then
		local current_is_float = vim.api.nvim_win_get_config(state.float_win).relative ~= ""
		local target_is_float = (mode == "float")

		if current_is_float ~= target_is_float then
			-- Switch mode: close current window without resetting buffer/origin, then re-open in new mode
			local win = state.float_win
			state.float_win = nil
			if vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_close(win, true)
			end
		else
			vim.api.nvim_set_current_win(state.float_win)
			return
		end
	end

	if not state.origin_win or not state.is_valid_win(state.origin_win) then
		state.origin_win = vim.api.nvim_get_current_win()
		state.origin_buf = origin_override or vim.api.nvim_win_get_buf(state.origin_win)
	end

	if mode == "split" then
		local side = config.options.split_side or "below"
		if side == "above" then
			vim.cmd("aboveleft split")
		elseif side == "left" then
			vim.cmd("topleft vsplit")
		elseif side == "right" then
			vim.cmd("botright vsplit")
		else -- "below" (default)
			vim.cmd("belowright split")
		end

		state.float_win = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_buf(state.float_win, state.float_buf)

		vim.wo[state.float_win].wrap = true
		vim.wo[state.float_win].linebreak = true
		vim.wo[state.float_win].number = true
		vim.wo[state.float_win].relativenumber = false
	else
		-- Floating window mode
		local width_ratio = config.options.width or 0.75
		local height_ratio = config.options.height or 0.70

		local width = math.floor(vim.o.columns * width_ratio)
		local height = math.floor(vim.o.lines * height_ratio)
		local row = math.floor((vim.o.lines - height) / 2)
		local col = math.floor((vim.o.columns - width) / 2)

		state.float_win = vim.api.nvim_open_win(state.float_buf, true, {
			relative = "editor",
			width = width,
			height = height,
			row = row,
			col = col,
			style = "minimal",
			border = "rounded",
			title = " Jotter ",
			title_pos = "center",
		})

		vim.wo[state.float_win].wrap = true
		vim.wo[state.float_win].linebreak = true
		vim.wo[state.float_win].number = false
		vim.wo[state.float_win].relativenumber = false
	end

	vim.bo[state.float_buf].filetype = "markdown"
	vim.bo[state.float_buf].bufhidden = "hide"
	vim.bo[state.float_buf].swapfile = false

	local ok, rm = pcall(require, "render-markdown")
	if ok and rm.enable then
		pcall(rm.enable, state.float_buf)
	end

	vim.bo[state.float_buf].modified = false

	local function close_and_restore()
		save_to_disk()
		local win = state.float_win
		local o_win = state.origin_win
		local o_buf = state.origin_buf

		state.reset()

		if state.is_valid_win(win) then
			vim.api.nvim_win_close(win, true)
		end

		if state.is_valid_win(o_win) then
			vim.api.nvim_set_current_win(o_win)
			if state.is_valid_buf(o_buf) then
				vim.api.nvim_win_set_buf(o_win, o_buf)
			end
		end
	end

	local close_key = config.options.keymaps and config.options.keymaps.toggle or "<leader>n"
	vim.keymap.set("n", close_key, close_and_restore, { buffer = state.float_buf, silent = true, desc = "Close Jotter" })
	vim.keymap.set("n", "q", close_and_restore, { buffer = state.float_buf, silent = true, desc = "Close Jotter" })
end

function M.close()
	if not state.is_valid_win(state.float_win) then
		return
	end

	save_to_disk()

	local win = state.float_win
	local o_win = state.origin_win
	local o_buf = state.origin_buf

	state.reset()

	if state.is_valid_win(win) then
		vim.api.nvim_win_close(win, true)
	end

	if state.is_valid_win(o_win) then
		vim.api.nvim_set_current_win(o_win)
		if state.is_valid_buf(o_buf) then
			vim.api.nvim_win_set_buf(o_win, o_buf)
		end
	end
end

return M
