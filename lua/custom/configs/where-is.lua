local M = {}

function M.copy_cur_buffer_abs_path()
  local abs_path = require("custom.utils.buf").get_cur_buf_path()
  print("Copied: " .. vim.inspect(abs_path))
  vim.fn.setreg("+", abs_path)
end

return M
