local buf_utils = require "custom.utils.buf"

local M = {}

local function get_all_wins_info()
  local cur_win_id = vim.api.nvim_get_current_win()

  local infos = {}
  for _, win_id in ipairs(vim.api.nvim_list_wins()) do
    local buf_id = vim.api.nvim_win_get_buf(win_id)
    local buf_name = vim.api.nvim_buf_get_name(buf_id)

    local is_need = not vim.startswith(buf_name, "NvimTree")

    if is_need then
      local win_config = vim.api.nvim_win_get_config(win_id)
      table.insert(infos, {
        name = buf_name,
        win_id = win_id,
        buf_id = buf_id,
        is_cur_win = cur_win_id == win_id,
        config = win_config,
      })
    end
  end

  return infos
end

function M.enlarge()
  local left, right = {}, {}
  local is_left = true

  local all_infos = get_all_wins_info()
  for _, win_info in ipairs(all_infos) do
    -- print(vim.inspect(win_info))
    if win_info.is_cur_win then
      is_left = false
    elseif is_left then
      table.insert(left, win_info)
    else
      table.insert(right, win_info)
    end
  end

  -- open other buffers to left one by one
  local width = 10
  for _, win_info in ipairs(vim.fn.reverse(left)) do
    vim.api.nvim_win_set_width(win_info.win_id, width)
    vim.api.nvim_win_set_config(win_info.win_id, {
      split = "left",
    })
    -- vim.api.nvim_win_close(win_info.win_id, false)
    -- vim.api.nvim_open_win(win_info.buf_id, false, {
    --   vertical = true,
    --   split = "left",
    --   width = width,
    -- })
  end

  -- open other buffers to right one by one
  width = 10
  for _, win_info in ipairs(vim.fn.reverse(right)) do
    vim.api.nvim_win_set_width(win_info.win_id, width)
    vim.api.nvim_win_set_config(win_info.win_id, {
      split = "right",
    })
    -- vim.api.nvim_win_close(win_info.win_id, false)
    -- vim.api.nvim_open_win(win_info.buf_id, false, {
    --   vertical = true,
    --   split = "right",
    --   width = width,
    -- })

    width = width + 10
  end
end

M.enlarge()

function M.swith_buffers()
  local all_win_infos = get_all_wins_info()
  if vim.fn.len(all_win_infos) ~= 2 then
    return
  end

  local a_win, b_win = all_win_infos[1], all_win_infos[2]
  vim.api.nvim_win_set_buf(a_win.win_id, b_win.buf_id)
  vim.api.nvim_win_set_buf(b_win.win_id, a_win.buf_id)
end

return M
