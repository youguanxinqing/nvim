local present, auto_session = pcall(require, "auto-session")
if not present then
	return
end

auto_session.setup({
	log_level = "error",
	auto_session_suppress_dirs = { "~/code" },
  cwd_change_handling = {
    restore_upcoming_session = true, -- This is necessary!!
  },
})

local present2, auto_session_nvim_tree = pcall(require, "auto-session-nvim-tree")
if not present2 then
  return
end
auto_session_nvim_tree.setup(auto_session)

