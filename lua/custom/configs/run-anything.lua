local terminal = require "nvterm.terminal"

local buf_utils = require "custom.utils.buf"
local table_utils = require "custom.utils.table"
local win_utils = require "custom.utils.win"

local M = {}

local function get_start_chunk_line(is_start_line)
  local pos = vim.api.nvim_win_get_cursor(0)
  local lnum = pos[1]

  for line_no = lnum, 1, -1 do
    local line = vim.fn.getline(line_no)
    if is_start_line(line, line_no) then
      return line
    end
  end

  return ""
end

function M.get_dashboard_info(name)
  local dashboard = {}
  local terminals = vim.fn.filter(vim.api.nvim_list_chans(), function(_, item)
    return item.mode == "terminal"
  end)
  for _, item in ipairs(terminals) do
    local buffer_name = string.sub(vim.api.nvim_buf_get_name(item.buffer), 0 - string.len(name), -1)
    if buffer_name == name then
      dashboard = {
        buffer_id = item.buffer,
        chan_id = item.id,
      }
    end
  end

  if dashboard.buffer_id then
    vim.api.nvim_buf_delete(dashboard.buffer_id, { force = true })
  end
  dashboard.buffer_id = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_buf_set_name(dashboard.buffer_id, name)
  dashboard.chan_id = vim.api.nvim_open_term(dashboard.buffer_id, {})

  dashboard.win_id = vim.api.nvim_open_win(0, false, {
    split = "below",
  })
  vim.api.nvim_win_set_buf(dashboard.win_id, dashboard.buffer_id)

  return dashboard
end

--- M.run_unit_test_for_go run unit test
function M.run_unit_test_for_go()
  local line = get_start_chunk_line(function(line)
    if string.match(line, "^func") then
      return true
    end
  end)

  local unit_name = string.match(line, "(Test[a-zA-Z0-9_]+)")
  if unit_name == nil then
    error(string.format("invalid test unit name in golang: '%s'", line))
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
    local unit_name = string.match(line, "func (Test[a-zA-Z0-9_]+)")
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

--- M.run_unit_test_for_lua run unit test
function M.run_unit_test_for_lua()
  local line = get_start_chunk_line(function(line)
    if string.match(line, "^function") then
      return true
    end
  end)

  if line == "" then
    error(string.format "not found test unit function for lua")
    return
  end

  local unit_name = string.match(line, "([Tt]?est[a-zA-Z0-9_]+)")
  if unit_name == nil then
    error(string.format("invalid test unit name in golang: '%s'", line))
    return
  end

  local cmd = string.format('lua dofile("%s").%s()', buf_utils.get_abs_buf_file(), unit_name)
  print("-- UnitTestName: " .. unit_name)
  print("-- " .. cmd)
  vim.cmd(cmd)
end

function M.run_unit_test_for_rust()
  local line = get_start_chunk_line(function(line, lnum)
    if string.match(line, "fn test_[a-zA-Z0-9_]+") then
      return vim.fn.match(vim.fn.getline(lnum - 1), "#%[test%]")
    end
  end)

  local unit_name = string.match(line, "(test[a-zA-Z0-9_]+)")
  if unit_name == nil then
    error(string.format("invalid test unit name in rust: '%s'", line))
    return
  end

  local module_path = ""
  local buf_name = buf_utils.get_buf_name_without_ext()
  if buf_name ~= "main" then
    local dir_path = buf_utils.get_relative_buf_dir()
    dir_path = vim.fn.filter(vim.fn.split(dir_path, "/"), function(_, chunk)
      if chunk == "" or chunk == "." or chunk == "src" then
        return false
      end
      return true
    end)
    table_utils.extend(dir_path, { buf_utils.get_buf_name_without_ext(), "" })
    module_path = vim.fn.join(dir_path, "::")
  end

  local path_to_unit_name = module_path .. "tests::" .. unit_name
  local cmd = { "cargo", "test", "--", "--exact", path_to_unit_name, "--show-output" }
  terminal.toggle "float"
  terminal.send(table.concat(cmd, " ", 1, #cmd), "float")
end

return M
