local string_utils = require "custom.utils.string"
local table_utils = require "custom.utils.table"

local M = {}

function M.get_cur_buf_dir()
  local relative_filepath = string.gsub(vim.api.nvim_buf_get_name(0), vim.loop.cwd(), "")
  local chunks = string_utils.split(relative_filepath, "/")
  chunks[vim.fn.len(chunks)] = ""
  return table_utils.join(chunks, "/")
end

return M
