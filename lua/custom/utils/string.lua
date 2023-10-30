local table_utils = require "custom.utils.table"

local M = {}

--- M.strip
--- @param s string|number
--- @param pattern nil|function
--- @return string
function M.strip(s, pattern)
  if type(pattern) == "function" then
    return pattern(s)
  end

  return s:match "^%s*(.-)%s*$"
end

function M.split(s, sep)
  if sep == nil then
    return { s }
  end

  local chunks = {}
  for item in string.gmatch(s, "([^" .. sep .. "]+)") do
    table.insert(chunks, item)
  end
  return chunks
end

--- M.splitn
--- @param s string
--- @param sep string
--- @param n number
--- @return table
function M.splitn(s, sep, n)
  if sep == nil or n <= 0 then
    return { s }
  end

  local chunks = {}
  for item in string.gmatch(s, "([^" .. sep .. "]+)") do
    table.insert(chunks, item)
  end

  local chunk_len = vim.fn.len(chunks)
  if n > (chunk_len - 1) then
    n = chunk_len - 1
  end

  local new_chunks = {}
  for i = 0, (n - 1) do
    table.insert(new_chunks, chunks[i + 1])
  end

  table.insert(new_chunks, vim.fn.join(table_utils.slice(chunks, n, chunk_len), sep))
  return new_chunks
end

return M
