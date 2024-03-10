local string_utils = require "custom.utils.string"
local table_utils = require "custom.utils.table"

local M = {}

--- M.get_cur_buf_dir return dir path of current buffer
function M.get_cur_buf_dir()
  local relative_filepath = string.gsub(vim.api.nvim_buf_get_name(0), vim.loop.cwd(), "")
  local chunks = string_utils.split(relative_filepath, "/")
  chunks[vim.fn.len(chunks)] = ""
  return table_utils.join(chunks, "/")
end

--- M.get_cur_buf_file return file path of current buffer
function M.get_cur_buf_file()
  local relative_filepath = string.gsub(vim.api.nvim_buf_get_name(0), vim.loop.cwd(), "")
  return "." .. relative_filepath
end

-- M.get_cur_buf_path return abs path of current buffer
function M.get_cur_buf_path()
  local abs_path = vim.api.nvim_buf_get_name(0)
  return abs_path
end

return M
