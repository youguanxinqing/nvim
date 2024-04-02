local string_utils = require "custom.utils.string"
local table_utils = require "custom.utils.table"

local M = {}

--- M.get_relative_buf_dir returns relative dir path of buffer
--- eg: {workspace}/path/to/dir_of_buffer
function M.get_relative_buf_dir()
  local relative_filepath = string.gsub(vim.api.nvim_buf_get_name(0), vim.loop.cwd(), "")
  local chunks = string_utils.split(relative_filepath, "/")
  chunks[vim.fn.len(chunks)] = ""
  return table_utils.join(chunks, "/")
end

M.get_cur_buf_dir = M.get_relative_buf_dir

--- M.get_relative_buf_file returns relative file path of buffer
--- eg: {workspace}/path/to/file_of_buffer
function M.get_relative_buf_file()
  local relative_filepath = string.gsub(vim.api.nvim_buf_get_name(0), vim.loop.cwd(), "")
  return "." .. relative_filepath
end

M.get_cur_buf_file = M.get_relative_buf_file

-- M.get_abs_buf_file returns abs file path of buffer
--- eg: {system_root}/path/to/file_of_buffer
function M.get_abs_buf_file()
  local abs_path = vim.api.nvim_buf_get_name(0)
  return abs_path
end

M.get_cur_buf_path = M.get_abs_buf_file

-- M.get_abs_buf_dir returns abs dir path of buffer
--- eg: {system_root}/path/to/dir_of_buffer
function M.get_abs_buf_dir()
  local abs_path = vim.api.nvim_buf_get_name(0)
  local chunks = string_utils.split(abs_path, "/")
  chunks[vim.fn.len(chunks)] = ""
  return table_utils.join(chunks, "/")
end

-- M.get_buf_name returns name of buffer
--- eg: xxx.lua
function M.get_buf_name()
  local abs_path = vim.api.nvim_buf_get_name(0)
  local chunks = string_utils.split(abs_path, "/")
  return chunks[vim.fn.len(chunks)]
end

-- M.get_buf_name_without_ext returns name of buffer without ext
--- eg: is "xxx" but not "xxx.lua"
function M.get_buf_name_without_ext()
  local buf_name = M.get_buf_name()
  local chunks = string_utils.split(buf_name, ".")
  local length = vim.fn.len(chunks)
  if length < 2 then
    return buf_name
  end
  return table_utils.join(table_utils.slice(chunks, 0, length - 1), ".")
end

-- M.is_ext returns whether extension of filename equals ext_flag
--- eg: 1. filename=xxx.lua, ext_flag=lua => true
---     2. filename=xxx.lua, ext_flag=go => false
function M.is_ext(filename, ext_flag)
  return M.get_ext(filename) == ext_flag
end

--- M.get_ext returns extension of filename
function M.get_ext(filename)
  local chunks = string_utils.split(filename, ".")
  local length = vim.fn.len(chunks)
  if length < 2 then
    return ""
  end
  return chunks[length]
end

local function test_functions()
  print("get_cur_buf_dir:", vim.inspect(M.get_cur_buf_dir()))
  print("get_cur_buf_file:", vim.inspect(M.get_cur_buf_file()))
  print("get_cur_buf_path:", vim.inspect(M.get_cur_buf_path()))
  print("get_abs_buf_dir:", vim.inspect(M.get_abs_buf_dir()))
  print("get_buf_name:", vim.inspect(M.get_buf_name()))

  print("get_buf_name_without_ext:", M.get_buf_name_without_ext())

  print("is_ext, expect true:", M.is_ext("xxx.lua", "lua"))
  print("is_ext, expect false:", M.is_ext("xxx.lua", "go"))

  print("get_ext:", M.get_ext "xxx.lua")
end

-- test_functions()

return M
