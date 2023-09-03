local is_present, winpick = pcall(require, "winpick")
if not is_present then
	return {
		select = function() end,
		setup = function() end,
	}
end

local select = function()
	local winid, _ = winpick.select()
	if winid then
		vim.api.nvim_set_current_win(winid)
	end
end

local setup = function()
	winpick.setup()
end

return {
	select = select,
	setup = setup,
}
