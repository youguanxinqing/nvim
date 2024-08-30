local M = {}

function M.recursive_create_file(filepath)
  local chunks = vim.fn.split(filepath, "/")
  local dirpath = table.concat(chunks, "/", 1, #chunks - 1)
  M.recursive_create_directory(dirpath)
  vim.system { "touch", filepath }
end

function M.recursive_create_directory(dirpath)
  vim.system { "mkdir", "-p", dirpath }
end

return M
