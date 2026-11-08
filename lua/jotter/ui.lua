--- @brief [[
--- UI and window management module for jotter.nvim.
--- Handles opening/closing floating or split windows, buffer initialization,
--- render-markdown integration, and buffer-local close keymaps.
--- ]]

local config = require("jotter.config")
local state = require("jotter.state")

local M = {}

local function ensure_file(filename, initial_header)
	local fname = filename or config.options.filename or "jotter.md"
	local p = vim.fn.stdpath("data") .. "/" .. fname
	if vim.fn.filereadable(p) == 0 then
		local dir = vim.fn.fnamemodify(p, ":h")
		vim.fn.mkdir(dir, "p")
		local fd = io.open(p, "w")
		if fd then
			fd:write(initial_header or "# Jotter\n\n")
			fd:close()
		end
	end
	return p
end

--- Captures current system clipboard text and appends it to the clipboard history file if new.
--- @param clip_filename string The filename for clipboard history.
local function capture_clipboard(clip_filename)
	local clip_text = vim.fn.getreg("+")
	if not clip_text or clip_text == "" then
		return
	end

	clip_text = vim.trim(clip_text)
	if clip_text == "" then
		return
	end

	local path = ensure_file(clip_filename, "# Clipboard History\n\n")

	local f = io.open(path, "r")
	local content = ""
	if f then
		content = f:read("*a")
		f:close()
	end

	if content:find(clip_text, 1, true) then
		return
	end

	local timestamp = os.date("%Y-%m-%d %H:%M:%S")
	local entry = string.format("\n## Clip [%s]\n\n```text\n%s\n```\n", timestamp, clip_text)

	local append_f = io.open(path, "a")
	if append_f then
		append_f:write(entry)
		append_f:close()
	end
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
--- @param origin_override number|nil Optional buffer handle to restore on close.
--- @param mode_override string|nil Optional mode override ("float" or "split").
--- @param filename_override string|nil Optional filename override (e.g. for clipboard tab).
--- @param title_override string|nil Optional window title override.
function M.open(origin_override, mode_override, filename_override, title_override)
	local filename = filename_override or config.options.filename or "jotter.md"

	if filename_override and filename_override == config.options.clip_filename then
		capture_clipboard(filename_override)
	end

	local path = ensure_file(filename, filename == config.options.clip_filename and "# Clipboard History\n\n" or "# Jotter\n\n")
	local mode = mode_override or config.options.open_mode or "float"
	local win_title = title_override or (filename == config.options.clip_filename and " Jotter Clipboard " or " Jotter ")

	if not state.is_valid_buf(state.float_buf) then
		state.float_buf = vim.fn.bufadd(path)
		vim.api.nvim_buf_set_name(state.float_buf, path)
	else
		local current_buf_name = vim.api.nvim_buf_get_name(state.float_buf)
		if current_buf_name ~= path then
			save_to_disk()
			state.float_buf = vim.fn.bufadd(path)
			vim.api.nvim_buf_set_name(state.float_buf, path)
		end
	end

	if not vim.api.nvim_buf_is_loaded(state.float_buf) then
		vim.fn.bufload(state.float_buf)
	end

	if state.is_valid_win(state.float_win) then
		local current_is_float = vim.api.nvim_win_get_config(state.float_win).relative ~= ""
		local target_is_float = (mode == "float")

		if current_is_float ~= target_is_float then
			local win = state.float_win
			state.float_win = nil
			if vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_close(win, true)
			end
		else
			vim.api.nvim_set_current_win(state.float_win)
			vim.api.nvim_win_set_buf(state.float_win, state.float_buf)
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
		else
			vim.cmd("belowright split")
		end

		state.float_win = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_buf(state.float_win, state.float_buf)

		vim.wo[state.float_win].wrap = true
		vim.wo[state.float_win].linebreak = true
		vim.wo[state.float_win].number = true
		vim.wo[state.float_win].relativenumber = false
	else
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
			title = win_title,
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
