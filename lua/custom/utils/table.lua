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
--- @return table
function M.extend(arr1, arr2)
  for _, item in pairs(arr2) do
    table.insert(arr1, item)
  end
end

return M
