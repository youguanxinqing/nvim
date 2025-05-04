local tbl_utils = require "custom.utils.table"
local buf_utils = require "custom.utils.buf"

local M = {}

local function _real_window_name(name)
  return string.format("%s/%s", vim.loop.cwd(), name)
end

--- @return integer (window id)
function M.display_content_to_window(window_name, title, content, direction)
  local _real_name = _real_window_name(window_name)

  local listed_bufs = buf_utils.listed_buf_infos()

  local buf_id, win_id = nil, nil
  -- find existed window
  for _, buf_info in ipairs(listed_bufs) do
    if _real_name == buf_info.name then
      buf_id = buf_info.bufnr
      if vim.fn.len(buf_info.windows) ~= 0 then
        win_id = buf_info.windows[1]
      end
    end
  end

  -- if it does not open, create a new window
  if win_id == nil then
    if not direction then
      direction = "right"
    end
    win_id = vim.api.nvim_open_win(0, false, {
      split = direction,
    })
  end

  -- if no buf, create a new buffer
  if buf_id == nil then
    buf_id = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_buf_set_name(buf_id, window_name)
  end

  vim.api.nvim_win_set_buf(win_id, buf_id)

  local lines = { title, "---" }
  tbl_utils.extend(lines, vim.fn.split(content, "\n"))
  vim.api.nvim_buf_set_lines(buf_id, 0, vim.fn.len(lines), false, lines)

  return win_id
end

function M.rename_window_name(name)
  local buf_id = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_name(buf_id, name)
end

function M.close_window_by_name(name)
  local _real_name = _real_window_name(name)

  local listed_bufs = buf_utils.listed_buf_infos()
  for _, buf_info in ipairs(listed_bufs) do
    if _real_name == buf_info.name then
      local buf_id = buf_info.bufnr
      if vim.fn.len(buf_info.windows) ~= 0 then
        local win_id = buf_info.windows[1]
        vim.api.nvim_win_close(win_id, true)
      end
      vim.api.nvim_buf_delete(buf_id, { force = true })
    end
  end
end

function M.diff_vsplit_file(window_name, file_path)
  -- keep current pos before diff
  local origin_win = vim.api.nvim_get_current_win()

  vim.cmd "diffthis"
  vim.cmd("vsplit " .. file_path)
  vim.cmd "diffthis"
  M.rename_window_name(window_name)

  -- restore original win
  vim.api.nvim_set_current_win(origin_win)
end

function M.close_diff_vsplit(window_name)
  vim.cmd "diffoff!"
  M.close_window_by_name(window_name)
end

return M
