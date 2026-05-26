local M = {}

local function is_nil_or_empty(tags)
  return tags == nil or tags == vim.NIL or vim.tbl_isempty(tags)
end

local function retry_inside_word(pattern, flags)
  if not flags:find("c", 1, true) then
    return vim.NIL
  end

  local word = vim.fn.expand "<cword>"
  if word == "" then
    return vim.NIL
  end

  local win = vim.api.nvim_get_current_win()
  local row, col = unpack(vim.api.nvim_win_get_cursor(win))
  local line = vim.api.nvim_get_current_line()
  local cursor_col = col + 1
  local start_col = line:find(word, 1, true)

  while start_col do
    local end_col = start_col + #word - 1
    if cursor_col >= start_col and cursor_col <= end_col then
      local candidates = {
        cursor_col + 1,
        cursor_col - 1,
        start_col + 1,
        end_col - 1,
        math.floor((start_col + end_col) / 2),
      }

      for _, candidate in ipairs(candidates) do
        if candidate >= start_col and candidate <= end_col and candidate ~= cursor_col then
          vim.api.nvim_win_set_cursor(win, { row, candidate - 1 })
          local tags = vim.lsp.tagfunc(pattern, flags)
          vim.api.nvim_win_set_cursor(win, { row, col })
          if not is_nil_or_empty(tags) then
            return tags
          end
        end
      end

      break
    end
    start_col = line:find(word, end_col + 1, true)
  end

  return vim.NIL
end

function M.tagfunc(pattern, flags)
  local tags = vim.lsp.tagfunc(pattern, flags)
  if not is_nil_or_empty(tags) then
    return tags
  end

  tags = retry_inside_word(pattern, flags)
  return is_nil_or_empty(tags) and vim.NIL or tags
end

function M.setup()
  _G.custom_lsp_tagfunc = M.tagfunc
end

return M
