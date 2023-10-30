local M = {}

--- M.is_identifier
--- @param s string
--- @return boolean
function M.is_identifier(s)
  if type(s) == "string" and string.len(s) > 0 and string.gsub(string.sub(s, 0, 1), "%d+", "") ~= "" then
    return true
  end
  return false
end

return M
