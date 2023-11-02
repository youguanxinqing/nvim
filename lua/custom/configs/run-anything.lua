local buf_utils = require "custom.utils.buf"

local M = {}

--- M.run_unit_test_for_go run unit test
function M.run_unit_test_for_go()
  local unit_name = string.match(vim.api.nvim_get_current_line(), "(Test[a-zA-Z0-9]+)")
  local cmd = "go test -v " .. buf_utils.get_cur_buf_dir() .. "*.go -run " .. unit_name
  print(cmd)
end

return M
