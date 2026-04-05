dofile(vim.g.base46_cache .. "lsp")

local function lspSymbol(name, icon)
  local hl = "DiagnosticSign" .. name
  vim.fn.sign_define(hl, { text = icon, numhl = hl, texthl = hl })
end
lspSymbol("Error", "󰅙")
lspSymbol("Info", "󰋼")
lspSymbol("Hint", "󰌵")
lspSymbol("Warn", "")

vim.diagnostic.config {
  virtual_text = { prefix = "" },
  signs = true,
  underline = true,
  update_in_insert = false,
}

local hover_config = { border = "single" }
local signature_help_config = {
  border = "single",
  focusable = false,
  relative = "cursor",
}
local lsp_util = require "vim.lsp.util"
local sig_help_ns = vim.api.nvim_create_namespace "custom.lsp.signature_help"

local default_hover = vim.lsp.buf.hover
vim.lsp.buf.hover = function(config)
  config = vim.tbl_deep_extend("force", vim.deepcopy(hover_config), config or {})
  return default_hover(config)
end

local default_signature_help = vim.lsp.buf.signature_help
vim.lsp.buf.signature_help = function(config)
  config = vim.tbl_deep_extend("force", vim.deepcopy(signature_help_config), config or {})
  return default_signature_help(config)
end

vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
  config = vim.tbl_deep_extend("force", vim.deepcopy(hover_config), config or {})
  if vim.api.nvim_get_current_buf() ~= ctx.bufnr then
    return
  end

  if not (result and result.contents) then
    if config.silent ~= true then
      vim.notify "No information available"
    end
    return
  end

  local format = "markdown"
  local contents
  if type(result.contents) == "table" and result.contents.kind == "plaintext" then
    format = "plaintext"
    contents = vim.split(result.contents.value or "", "\n", { trimempty = true })
  else
    contents = lsp_util.convert_input_to_markdown_lines(result.contents)
  end

  if vim.tbl_isempty(contents) then
    if config.silent ~= true then
      vim.notify "No information available"
    end
    return
  end

  config.focus_id = ctx.method
  return lsp_util.open_floating_preview(contents, format, config)
end

vim.lsp.handlers["textDocument/signatureHelp"] = function(err, result, ctx, config)
  config = vim.tbl_deep_extend("force", vim.deepcopy(signature_help_config), config or {})
  if vim.api.nvim_get_current_buf() ~= ctx.bufnr then
    return
  end

  if not (result and result.signatures and result.signatures[1]) then
    if config.silent ~= true then
      print "No signature help available"
    end
    return
  end

  local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
  local triggers =
    vim.tbl_get(client.server_capabilities, "signatureHelpProvider", "triggerCharacters")
  local ft = vim.bo[ctx.bufnr].filetype
  local lines, hl = lsp_util.convert_signature_help_to_markdown_lines(result, ft, triggers)

  if not lines or vim.tbl_isempty(lines) then
    if config.silent ~= true then
      print "No signature help available"
    end
    return
  end

  config.focus_id = ctx.method
  local bufnr, winid = lsp_util.open_floating_preview(lines, "markdown", config)

  if hl then
    vim.hl.range(
      bufnr,
      sig_help_ns,
      "LspSignatureActiveParameter",
      { hl[1], hl[2] },
      { hl[3], hl[4] }
    )
  end

  return bufnr, winid
end

local M = {}
local utils = require "core.utils"

-- export on_attach & capabilities for custom lspconfigs

M.on_attach = function(client, bufnr)
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false

  utils.load_mappings("lspconfig", { buffer = bufnr })

  if client.server_capabilities.signatureHelpProvider then
    require("nvchad.signature").setup(client)
  end

  if not utils.load_config().ui.lsp_semantic_tokens and client.supports_method "textDocument/semanticTokens" then
    client.server_capabilities.semanticTokensProvider = nil
  end
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()

M.capabilities.textDocument.completion.completionItem = {
  documentationFormat = { "markdown", "plaintext" },
  snippetSupport = true,
  preselectSupport = true,
  insertReplaceSupport = true,
  labelDetailsSupport = true,
  deprecatedSupport = true,
  commitCharactersSupport = true,
  tagSupport = { valueSet = { 1 } },
  resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  },
}

-- Configure lua_ls using new vim.lsp.config API
vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
  on_attach = M.on_attach,
  capabilities = M.capabilities,
  root_markers = {
    ".luarc.json",
    ".luarc.jsonc",
    ".luacheckrc",
    ".stylua.toml",
    "stylua.toml",
    "selene.toml",
    "selene.yml",
    ".git",
  },
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = {
          [vim.fn.expand "$VIMRUNTIME/lua"] = true,
          [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
          [vim.fn.stdpath "data" .. "/lazy/ui/nvchad_types"] = true,
          [vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy"] = true,
        },
        maxPreload = 100000,
        preloadFileSize = 10000,
      },
      completion = {
        callSnippet = "Replace",
      },
    },
  },
})

-- Enable lua_ls
vim.lsp.enable "lua_ls"

return M
