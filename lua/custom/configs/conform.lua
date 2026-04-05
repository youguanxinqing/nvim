local prettier_filetypes = {
  html = true,
  markdown = true,
  css = true,
}

local function has_prettier()
  return vim.fn.executable "prettierd" == 1 or vim.fn.executable "prettier" == 1
end

require("conform").setup {
  formatters_by_ft = {
    html = { "prettierd", "prettier", stop_after_first = true },
    markdown = { "prettierd", "prettier", stop_after_first = true },
    css = { "prettierd", "prettier", stop_after_first = true },
    lua = { "stylua" },
    cpp = { "clang_format" },
    c = { "clang_format" },
    go = { "goimports", "gofmt" },
  },
  format_on_save = function(bufnr)
    local filetype = vim.bo[bufnr].filetype
    if prettier_filetypes[filetype] and not has_prettier() then
      return
    end

    return {
      timeout_ms = 500,
      lsp_fallback = false,
    }
  end,
}
