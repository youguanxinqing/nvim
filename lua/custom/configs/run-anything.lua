local buf_utils = require "custom.utils.buf"

local M = {}

--- M.run_unit_test_for_go run unit test
function M.run_unit_test_for_go()
  local cur_line = vim.api.nvim_get_current_line()
  local unit_name = string.match(cur_line, "(Test[a-zA-Z0-9]+)")
  if unit_name == nil then
    error(string.format("invalid test unit name in golang: '%s'", cur_line))
    return
  end

  local cmd = "go test -v " .. buf_utils.get_cur_buf_dir() .. "*.go -run " .. unit_name
  local terminal = require "nvterm.terminal"
  terminal.toggle "float"
  terminal.send(cmd, "float")
end

--- M.run_current_script_for_py run current script
function M.run_current_script_for_py()
  local project_root_dir = vim.loop.cwd()
  local cmd = string.format("export PYTHONPATH=%s && python %s", project_root_dir, buf_utils.get_cur_buf_file())

  local terminal = require "nvterm.terminal"
  terminal.toggle "float"
  terminal.send(cmd, "float")
end

return M
