require("conform").setup {
  formatters_by_ft = {
    html = { "prettier" },
    markdown = { "prettier" },
    css = { "prettier" },
    lua = { "stylua" },
    cpp = { "clang_format" },
    c = { "clang_format" },
    go = { "goimports", "gofmt" },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = false,
  },
}
