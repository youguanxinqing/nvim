local string_utils = require "custom.utils.string"
local table_utils = require "custom.utils.table"
local validator_utils = require "custom.utils.validator"

local M = {}

local enum_line = { name = "", typ = "", op = "", iota = "", value = "", comment = "" }

-- enum_line:new
--- @param obj any
--- @return table
function enum_line:new(obj)
  obj = obj or { name = "", typ = "", op = "", iota = "", value = "", commen = "" }
  setmetatable(obj, self)
  self.__index = self
  return obj
end

--- enum_line:new_from_string
--- example:
---   Apple Fruit = iota + 1
---   Apple Fruit =  1
---   Apple = 1
---   Apple
---
--- @param line string
--- @return table, 0|1
function enum_line:new_from_string(line)
  local items = {}
  for item in string.gmatch(line, '["=+0-9a-zA-Z]+') do
    table.insert(items, item)
  end

  local obj = enum_line:new()
  local len = #items
  if len == 1 then
    obj.name = items[1]
  elseif len == 3 then
    obj.name, obj.op, obj.value = items[1], items[2], items[3]
  elseif len == 4 then
    obj.name, obj.typ, obj.op, obj.value = items[1], items[2], items[3], items[4]
  elseif len == 6 then
    obj.name, obj.typ, obj.op, obj.iota, obj.value = items[1], items[2], items[3], items[4], items[6]
  else
    return {}, 0
  end

  if validator_utils.is_identifier(obj.name) == 0 then
    return {}, 0
  end

  if string.len(obj.typ) > 0 and validator_utils.is_identifier(obj.typ) == 0 then
    return {}, 0
  end

  local chunks_by_sep = string_utils.splitn(line, "//", 1)
  if vim.fn.len(chunks_by_sep) > 1 then
    obj.comment = string_utils.strip(chunks_by_sep[2], nil)
  end

  return obj, 1
end

local case_template = "\tcase %s:"
local return_template = '\t\treturn "%s"'

--- enum_string_template
--- @param typ string
--- @param body table
--- @return table
local function enum_string_template(typ, body)
  local string_method = {}
  table.insert(string_method, string.format("func (%s %s) String() string {", string.lower(string.sub(typ, 0, 1)), typ))
  table.insert(string_method, string.format("\tswitch %s {", string.lower(string.sub(typ, 0, 1))))
  table_utils.extend(string_method, body)
  table.insert(string_method, "\tdefault:")
  table.insert(string_method, '\t\treturn "UNKNOWN"')
  table.insert(string_method, "\t}")
  table.insert(string_method, "}")
  table.insert(string_method, "")
  return string_method
end

function M.enum_to_string()
  -- record init pos
  local pos = vim.api.nvim_win_get_cursor(0)

  -- retrieve code with the z-register as intermediary
  vim.cmd.normal { '"zya)', bang = true }
  local enum_code_stmt = vim.fn.getreg "z"

  local lines = vim.fn.split(tostring(enum_code_stmt), "\n")
  local new_lines = {}
  for idx, line in pairs(lines) do
    local cleaned_line = string_utils.strip(line, nil)
    -- end flag
    if cleaned_line == ")" then
      break
    end

    -- check if constant code is valid
    if idx == 1 and cleaned_line ~= "(" then
      error(string.format("illegal enum constant code err: line=%s", line))
      return
    end

    if idx >= 2 and line ~= "" then
      local enum_obj, errno = enum_line:new_from_string(cleaned_line)
      if errno == 0 then
        error(
          string.format(
            "invalid enum line err: line='%s', idx=%d, errno=%d, enum_obj=%s",
            cleaned_line,
            idx,
            errno,
            vim.inspect(enum_obj)
          )
        )
        return
      end
      table.insert(new_lines, enum_obj)
    end
  end
  if vim.fn.len(new_lines) < 1 then
    error "no invalid enum code statement"
    return
  end

  local code_stmt = {}

  -- if value is digtal
  if tonumber(new_lines[1].value) then
    for _, line in pairs(new_lines) do
      table.insert(code_stmt, string.format(case_template, line.name))
      table.insert(code_stmt, string.format(return_template, line.name))
    end
  else
    for _, line in pairs(new_lines) do
      table.insert(code_stmt, string.format(case_template, line.name))
      table.insert(code_stmt, string.format(return_template, line.comment))
    end
  end

  local cur_pos = vim.api.nvim_win_get_cursor(0)
  local insert_row_no = cur_pos[1] + vim.fn.len(code_stmt) / 2 + 2
  vim.api.nvim_buf_set_lines(0, insert_row_no, insert_row_no, false, enum_string_template(new_lines[1].typ, code_stmt))

  -- restore int pos
  vim.api.nvim_win_set_cursor(0, pos)
end

return M
