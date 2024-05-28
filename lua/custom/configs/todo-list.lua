local string_utils = require "custom.utils.string"

local M = {}

local function retrieve_todo_list()
  local qf_list = {}

  local grep_text = vim.fn.system { "rg", "-i", "todo", "--vimgrep" }
  local grep_results = string_utils.split(grep_text, "\n")

  for _, line in pairs(grep_results) do
    local chunks = string_utils.split(line, ":")
    if vim.fn.len(chunks) == 4 then
      table.insert(qf_list, {
        filename = chunks[1],
        lnum = chunks[2],
        text = chunks[4],
      })
    end
  end

  return qf_list
end

function M.toggle_todo_list()
  local qf_list = retrieve_todo_list()

  vim.api.nvim_command "copen"
  vim.fn.setqflist(qf_list)
  vim.fn.setqflist({}, "r", { title = "TODO" })
end

return M
