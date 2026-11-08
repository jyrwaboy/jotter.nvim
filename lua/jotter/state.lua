--- @brief [[
--- State management module for jotter.nvim.
--- Tracks floating window handles, scratchpad buffers, and origin windows.
--- ]]

local M = {
	float_win = nil,
	float_buf = nil,
	origin_win = nil,
	origin_buf = nil,
}

--- Checks whether the given window handle references an existing and valid Neovim window.
--- @param w number|nil Window handle ID to check.
--- @return boolean True if `w` is truthy and `vim.api.nvim_win_is_valid(w)` returns true, false otherwise.
function M.is_valid_win(w)
	return w and vim.api.nvim_win_is_valid(w)
end

--- Checks whether the given buffer handle references an existing and valid Neovim buffer.
--- @param b number|nil Buffer handle ID to check.
--- @return boolean True if `b` is truthy and `vim.api.nvim_buf_is_valid(b)` returns true, false otherwise.
function M.is_valid_buf(b)
	return b and vim.api.nvim_buf_is_valid(b)
end

--- Resets all internal window and buffer state handles to nil.
--- Used when closing the scratchpad or cleaning up stale window references.
function M.reset()
	M.float_win = nil
	M.float_buf = nil
	M.origin_win = nil
	M.origin_buf = nil
end

return M
