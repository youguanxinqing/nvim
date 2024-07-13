local terminal = require "nvterm.terminal"

local buf_utils = require "custom.utils.buf"
local table_utils = require "custom.utils.table"

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
  terminal.toggle "float"
  terminal.send(cmd, "float")
end

-- M.run_file_test_for_go run all unit tests in current file
function M.run_file_tests_for_go()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  local unit_names = {}
  for _, line in ipairs(lines) do
    local unit_name = string.match(line, "func (Test[a-zA-Z0-9]+)")
    if unit_name ~= nil then
      table.insert(unit_names, unit_name)
    end
  end

  if vim.fn.len(unit_names) == 0 then
    error(string.format("no unit test in current file()'", buf_utils.get_buf_name()))
    return
  end

  local patten = "'^(" .. table_utils.join(unit_names, "|") .. ")$'"
  local cmd = "go test -v " .. buf_utils.get_cur_buf_dir() .. "*.go -run " .. patten
  terminal.toggle "float"
  terminal.send(cmd, "float")
end

--- M.run_current_script_for_py run current script
function M.run_current_script_for_py()
  local project_root_dir = vim.loop.cwd()
  local cmd = string.format("export PYTHONPATH=%s && python %s", project_root_dir, buf_utils.get_cur_buf_file())

  terminal.toggle "float"
  terminal.send(cmd, "float")
end

return M
