local M = {}

--- M.find
--- @param arr table
--- @param elem any
--- @return 0|1
function M.find(arr, elem)
  for item in pairs(arr) do
    if item == elem then
      return 1
    end
  end
  return 0
end

--- M.extend
--- @param arr1 table
--- @param arr2 table
function M.extend(arr1, arr2)
  for _, item in pairs(arr2) do
    table.insert(arr1, item)
  end
end

--- M.extend
--- Note that left closed boundary is start, right closed arr is _end. (also left is closed and right is closed)
--- @param arr table
--- @param start number|nil
--- @param _end number|nil
--- @param step number|nil
function M.slice(arr, start, _end, step)
  start, _end, step = start or 0, _end or #arr, step or 1

  local sliced = {}
  if _end < start or start > #arr then
    return sliced
  end
  if not _end or _end > #arr then
    _end = #arr
  end

  for i = start + 1, _end, step do
    table.insert(sliced, arr[i])
  end

  return sliced
end

--- test
-- print(vim.inspect(M.slice({ 1, 2, 3, 4 }, 2, 4)))
-- print(vim.inspect(M.slice({ 1, 2, 3, 4 }, 4)))

--- M.join
--- @param tbl table
--- @param sep string
--- @return string
function M.join(tbl, sep)
  local str = ""

  local length = #tbl
  for i = 1, length - 1, 1 do
    str = str .. tostring(tbl[i]) .. sep
  end
  str = str .. tostring(tbl[length])
  return str
end

--- test
-- print(M.join({ 1, 2, 3, 4 }, ","))
-- print(M.join({ 1 }, ","))

--- M.flatten
--- @param arr table
--- @return table
function M.flatten(arr)
  return vim.iter(arr):flatten(10):totable()
end

return M
