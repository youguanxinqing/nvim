local M = {}

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "LSP" })
end

local function configured_servers()
  local seen = {}
  local servers = {}
  local configs = vim.lsp.config and vim.lsp.config._configs or {}

  for name in pairs(configs) do
    seen[name] = true
    servers[#servers + 1] = name
  end

  for _, path in ipairs(vim.api.nvim_get_runtime_file("lsp/*.lua", true)) do
    local name = vim.fn.fnamemodify(path, ":t:r")
    if not seen[name] then
      seen[name] = true
      servers[#servers + 1] = name
    end
  end

  table.sort(servers)
  return servers
end

local function complete_config(arg)
  return vim.tbl_filter(function(name) return vim.startswith(name, arg) end, configured_servers())
end

local function complete_client(arg)
  local seen = {}
  local servers = {}

  for _, client in ipairs(vim.lsp.get_clients()) do
    if not seen[client.name] and vim.startswith(client.name, arg) then
      seen[client.name] = true
      servers[#servers + 1] = client.name
    end
  end

  table.sort(servers)
  return servers
end

local function valid_server(name)
  if vim.lsp.config[name] ~= nil then
    return true
  end

  notify(("Invalid server name '%s'"):format(name), vim.log.levels.WARN)
  return false
end

local function server_filetypes(name)
  local ok, config = pcall(function() return vim.lsp.config[name] end)
  if not ok or type(config) ~= "table" then
    return nil
  end
  return config.filetypes
end

local function servers_for_current_buffer()
  local ft = vim.bo.filetype
  local servers = {}

  for _, name in ipairs(configured_servers()) do
    local filetypes = server_filetypes(name)
    if filetypes and vim.tbl_contains(filetypes, ft) then
      servers[#servers + 1] = name
    end
  end

  return servers
end

local function active_servers_for_current_buffer()
  local seen = {}
  local servers = {}

  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    if not seen[client.name] then
      seen[client.name] = true
      servers[#servers + 1] = client.name
    end
  end

  table.sort(servers)
  return servers
end

local function normalize_servers(info, default)
  local servers = #info.fargs > 0 and vim.deepcopy(info.fargs) or default()
  return vim.tbl_filter(valid_server, servers)
end

local function has_clients(name)
  return #vim.lsp.get_clients({ name = name }) > 0
end

local function stop_server(name, force)
  vim.lsp.enable(name, false)

  if force then
    for _, client in ipairs(vim.lsp.get_clients({ name = name })) do
      client:stop(true)
    end
  end
end

local function wait_until_stopped(names, callback)
  local pending = {}
  local stopped = {}
  local timed_out = {}

  for _, name in ipairs(names) do
    pending[name] = true
  end

  local timer = assert(vim.uv.new_timer())
  local started = vim.uv.now()

  timer:start(100, 100, function()
    local remaining = {}
    local expired = vim.uv.now() - started >= 3000

    for name in pairs(pending) do
      if not has_clients(name) then
        stopped[#stopped + 1] = name
      elseif expired then
        timed_out[#timed_out + 1] = name
      else
        remaining[name] = true
      end
    end

    pending = remaining
    if next(pending) ~= nil then
      return
    end

    if not timer:is_closing() then
      timer:stop()
      timer:close()
    end

    vim.schedule(function() callback(stopped, timed_out) end)
  end)
end

function M.start(info)
  local servers = normalize_servers(info, servers_for_current_buffer)
  if #servers == 0 then
    notify("No configured LSP servers match this buffer", vim.log.levels.WARN)
    return
  end

  vim.lsp.enable(servers)
end

function M.stop(info)
  local servers = normalize_servers(info, active_servers_for_current_buffer)
  if #servers == 0 then
    notify("No active LSP clients for this buffer", vim.log.levels.WARN)
    return
  end

  for _, name in ipairs(servers) do
    stop_server(name, info.bang)
  end
end

function M.restart(info)
  local servers = normalize_servers(info, active_servers_for_current_buffer)
  if #servers == 0 then
    if #info.fargs == 0 then
      M.start(info)
    end
    return
  end

  for _, name in ipairs(servers) do
    stop_server(name, info.bang)
  end

  wait_until_stopped(servers, function(stopped, timed_out)
    if #stopped > 0 then
      vim.lsp.enable(stopped)
    end

    if #timed_out > 0 then
      notify(
        ("Timed out waiting for %s to stop; use :LspRestart! to force"):format(table.concat(timed_out, ", ")),
        vim.log.levels.WARN
      )
    end
  end)
end

function M.setup()
  vim.api.nvim_create_user_command("LspLog", function()
    vim.cmd.edit(vim.lsp.log.get_filename())
  end, { desc = "Open LSP log file" })

  vim.api.nvim_create_user_command("LspStart", M.start, {
    desc = "Enable and start LSP servers for the current buffer",
    nargs = "*",
    complete = complete_config,
  })

  vim.api.nvim_create_user_command("LspStop", M.stop, {
    bang = true,
    desc = "Disable and stop LSP clients for the current buffer",
    nargs = "*",
    complete = complete_client,
  })

  vim.api.nvim_create_user_command("LspRestart", M.restart, {
    bang = true,
    desc = "Restart LSP clients for the current buffer",
    nargs = "*",
    complete = complete_client,
  })
end

return M
