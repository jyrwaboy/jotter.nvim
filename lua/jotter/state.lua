local M = {
	float_win = nil,
	float_buf = nil,
	origin_win = nil,
	origin_buf = nil,
}

--- Checks if a window ID is valid.
--- @param w number Window handle
--- @return boolean True if valid window
function M.is_valid_win(w)
	return w and vim.api.nvim_win_is_valid(w)
end

--- Checks if a buffer ID is valid.
--- @param b number Buffer handle
--- @return boolean True if valid buffer
function M.is_valid_buf(b)
	return b and vim.api.nvim_buf_is_valid(b)
end

--- Resets all state handles.
function M.reset()
	M.float_win = nil
	M.float_buf = nil
	M.origin_win = nil
	M.origin_buf = nil
end

return M
