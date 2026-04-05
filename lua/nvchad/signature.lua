local config = require("core.utils").load_config().ui.lsp.signature

local M = {}
local util = require "vim.lsp.util"
local sig_help_ns = vim.api.nvim_create_namespace "nvchad.signature_help"

M.signature_window = function(err, result, ctx, handler_config)
  if vim.api.nvim_get_current_buf() ~= ctx.bufnr then
    return
  end

  if not (result and result.signatures and result.signatures[1]) then
    if handler_config.silent ~= true then
      print "No signature help available"
    end
    return
  end

  local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
  local triggers =
    vim.tbl_get(client.server_capabilities, "signatureHelpProvider", "triggerCharacters")
  local ft = vim.bo[ctx.bufnr].filetype
  local lines, hl = util.convert_signature_help_to_markdown_lines(result, ft, triggers)

  if not lines or vim.tbl_isempty(lines) then
    if handler_config.silent ~= true then
      print "No signature help available"
    end
    return
  end

  local bufnr, winner = util.open_floating_preview(lines, "markdown", handler_config)

  if hl then
    vim.hl.range(
      bufnr,
      sig_help_ns,
      "LspSignatureActiveParameter",
      { hl[1], hl[2] },
      { hl[3], hl[4] }
    )
  end

  local current_cursor_line = vim.api.nvim_win_get_cursor(0)[1]

  if winner and current_cursor_line > 3 then
    vim.api.nvim_win_set_config(winner, {
      anchor = "SW",
      relative = "cursor",
      row = 0,
      col = -1,
    })
  end

  if bufnr and winner then
    return bufnr, winner
  end
end

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local clients = {}

local check_trigger_char = function(line_to_cursor, triggers)
  if not triggers then
    return false
  end

  for _, trigger_char in ipairs(triggers) do
    local current_char = line_to_cursor:sub(#line_to_cursor, #line_to_cursor)
    local prev_char = line_to_cursor:sub(#line_to_cursor - 1, #line_to_cursor - 1)
    if current_char == trigger_char then
      return true
    end
    if current_char == " " and prev_char == trigger_char then
      return true
    end
  end
  return false
end

local open_signature = function()
  local triggered = false

  for _, client in pairs(clients) do
    local provider = client.server_capabilities.signatureHelpProvider
    local triggers = provider and provider.triggerCharacters

    if client.name == "csharp" then
      triggers = { "(", "," }
    end

    local pos = vim.api.nvim_win_get_cursor(0)
    local line = vim.api.nvim_get_current_line()
    local line_to_cursor = line:sub(1, pos[2])

    if not triggered then
      triggered = check_trigger_char(line_to_cursor, triggers)
    end
  end

  if triggered then
    local params = util.make_position_params()
    local handler_config = {
      border = "single",
      focusable = false,
      silent = config.silent,
    }

    vim.lsp.buf_request(0, "textDocument/signatureHelp", params, function(err, result, ctx)
      return M.signature_window(err, result, ctx, handler_config)
    end)
  end
end

M.setup = function(client)
  if config.disabled then
    return
  end

  table.insert(clients, client)
  local group = augroup("LspSignature", { clear = false })
  vim.api.nvim_clear_autocmds { group = group, pattern = "<buffer>" }

  autocmd("TextChangedI", {
    group = group,
    pattern = "<buffer>",
    callback = function()
      local active_clients = vim.lsp.get_active_clients()
      if #active_clients < 1 then
        return
      end

      open_signature()
    end,
  })
end

return M
