local M = {}

--- M.is_identifier
--- @param s string
--- @return 0|1
function M.is_identifier(s)
  if type(s) == "string" and string.len(s) > 0 and string.gsub(string.sub(s, 0, 1), "%d+", "") ~= "" then
    return 1
  end
  return 0
end

return M
