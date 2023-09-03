local is_present, dir_telescope = pcall(require, "dir-telescope")
if not is_present then
	return {
		setup = function() end,
	}
end

local find_command = function()
	if 1 == vim.fn.executable("fd") then
		-- for fd
		return { "fd", "--type", "d", "--color", "never", "-E", ".git" }
	elseif 1 == vim.fn.executable("find") and vim.fn.has("win32") == 0 then
		-- for find
		return { "find", ".", "-type", "d", "-not", "-path", "*/.git/*" }
	end
end

local setup = function()
	dir_telescope.setup({
		find_command = find_command,
		hide = true,
		no_ignore = false,
		show_preview = true,
	})

	require("telescope").load_extension("dir")
end

return {
	setup = setup,
}
