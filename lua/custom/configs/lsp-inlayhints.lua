local present, inlayhints = pcall(require, "lsp-inlayhints")
if not present then
  return
end

local M = {}

vim.api.nvim_set_hl(0, "CustomizeLspInlayHint", { fg = "#d8d8d8", bg = "#3a3a3a" })

M.opts = {
  inlay_hints = {
    highlight = "CustomizeLspInlayHint",
    labels_separator = " ",
  },
  enabled_at_startup = false,
}

vim.api.nvim_create_augroup("LspAttach_inlayhints", {})

vim.api.nvim_create_autocmd("LspAttach", {
  group = "LspAttach_inlayhints",
  callback = function(args)
    if not (args.data and args.data.client_id) then
      return
    end

    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    inlayhints.on_attach(client, bufnr)
  end,
})

vim.cmd [[command! InlayHintsToggle lua require('lsp-inlayhints').toggle()]]

M.setup = function(opts)
  require("lsp-inlayhints").setup(opts)
end

return M
