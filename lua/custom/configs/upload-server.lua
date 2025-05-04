local buf_utils = require "custom.utils.buf"
local table_utils = require "custom.utils.table"
local win_utils = require "custom.utils.win"

local Menu = require "nui.menu"
local notify = require "notify"
notify.setup {
  max_width = function()
    return 80
  end,
  render = "wrapped-compact",
  timeout = 3000,
}

local function wrapper_notify(msg, level)
  notify(msg, level, {
    title = "Upload Server",
  })
end

local M = {}

-- upload server config
-- example:
-- local upload_configs = {
--   {
--      name = "your project root name",
--      enable_ssl = false,
--      target_root_dir = "project root name on remote server",  -- note: must endswith '/'
--      servers = {
--        {name = "alias name", addr = "1.1.1.1:8080", host = ""}
--      }
--   }
-- }

local configs = {
  {
    name = "nvim",
    enable_ssl = false,
    target_root_dir = "/tmp/test/",
    servers = {
      { name = "mine1", addr = "127.0.0.1:9091" },
      { name = "mine2", addr = "127.0.0.1:9091", host = "xxx.com" },
    },
  },
}

local default_upload_filename = ".upload_specified_files.txt"

local function get_config()
  local root_name = buf_utils.get_root_name()
  for _, one_config in ipairs(configs) do
    if one_config.name == root_name then
      return one_config
    end
  end

  local msg = string.format("Not find name='%s', pls add configuration for '%s' firstly!", root_name, root_name)
  vim.notify(msg, vim.log.levels.ERROR)
  return nil
end

local function show_menu(lines, on_submit, on_close)
  Menu({
    position = "50%",
    size = {
      width = 30,
      height = 10,
    },
    border = {
      style = "single",
      text = {
        top = "Choose Your Server:",
        top_align = "center",
      },
    },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:Normal",
    },
  }, {
    lines = lines,
    max_width = 20,
    keymap = {
      focus_next = { "j", "<Down>", "<Tab>" },
      focus_prev = { "k", "<Up>", "<S-Tab>" },
      close = { "<Esc>", "<C-c>" },
      submit = { "<CR>", "<Space>" },
    },
    on_submit = on_submit,
    on_close = on_close,
  }):mount()
end

local function encode_line(idx, server)
  -- using host if it exists, otherwise using addr
  if server.host ~= nil and server.host ~= "" then
    return string.format("%s. %s -> %s", idx, server.name, server.host)
  end
  return string.format("%s. %s -> %s", idx, server.name, server.addr)
end

local function decode_line(line)
  local chunks = vim.fn.split(line, " ")
  local idx = string.gsub(chunks[1], "[.]", "")
  return {
    idx = tonumber(idx),
    display_name = chunks[2],
  }
end

local function make_ssl_chunk(config)
  local ssl_chunk = ""
  if config.enable_ssl == true then
    ssl_chunk = "--enable-insecure-ssl"
  end
  return ssl_chunk
end

local function make_host_chunk(target, config)
  local host_chunk = ""

  local one_server = config.servers[target.idx]
  if one_server.host ~= nil and one_server.host ~= "" then
    host_chunk = string.format("--host %s", one_server.host)
  end
  return host_chunk
end

local function make_addr_chunk(target, config)
  return config.servers[target.idx].addr
end

local function run_upload(target, config)
  -- command format: sync-client --addr [remote_host]:[remote_port] \
  --               push \
  --               --local-file-path [local_file_path] \
  --               --remote-file-path [remote_file_path]
  --               --host xxx.com
  -- print(target.idx, target.display_name)

  local local_file_path = buf_utils.get_abs_buf_file()
  local remote_file_path = config.target_root_dir .. buf_utils.get_relative_buf_file()
  local cmd = string.format(
    "sync-client --addr %s %s %s push --local-file-path %s --remote-file-path %s",
    make_addr_chunk(target, config),
    make_host_chunk(target, config),
    make_ssl_chunk(config),
    local_file_path,
    remote_file_path
  )

  local output = vim.fn.system(cmd)
  if vim.v.shell_error == 0 then
    wrapper_notify(output, vim.log.levels.INFO)
  else
    wrapper_notify(output, vim.log.levels.ERROR)
  end
end

local function validate_executable_bin()
  local bin_name = "sync-client"
  if 1 ~= vim.fn.executable(bin_name) then
    wrapper_notify("Missing executable binary file: " .. bin_name, vim.log.levels.ERROR)
    return -1
  end
end

function M.upload_server()
  if -1 == validate_executable_bin() then
    return
  end

  local config = get_config()
  if config == nil then
    return
  end

  local lines = {}
  for idx, server in ipairs(config.servers) do
    table.insert(lines, Menu.item(encode_line(idx, server)))
  end

  show_menu(lines, function(item)
    run_upload(decode_line(item.text), config)
  end, function()
    wrapper_notify("Cancel upload", vim.log.levels.WARN)
  end)
end

local function run_upload_for_many_files(files, target, config)
  -- command format: sync-client --addr [remote_host]:[remote_port] \
  --               --host xxx.com \
  --               push \
  --               --file-mappings local_path1:remote_path1,local_path2:remote_path2,...
  local project_root_dir = vim.loop.cwd()

  local mappings = {}
  for _, file in ipairs(files) do
    table.insert(mappings, string.format("%s/%s:%s%s", project_root_dir, file, config.target_root_dir, file))
  end

  local cmd = string.format(
    "sync-client --addr %s %s %s push --file-mappings %s",
    make_addr_chunk(target, config),
    make_host_chunk(target, config),
    make_ssl_chunk(config),
    table.concat(mappings, ",")
  )

  local output = vim.fn.system(cmd)
  if vim.v.shell_error == 0 then
    wrapper_notify(output, vim.log.levels.INFO)
  else
    wrapper_notify(output, vim.log.levels.ERROR)
  end
end

function M.upload_files_changed()
  if -1 == validate_executable_bin() then
    return
  end

  local config = get_config()
  if config == nil then
    return
  end

  local server_lines = {}
  for idx, server in ipairs(config.servers) do
    table.insert(server_lines, Menu.item(encode_line(idx, server)))
  end

  -- get all modified files
  local changed_files = vim.fn.systemlist { "git", "ls-files", "-m" }
  local staged_files = vim.fn.systemlist { "git", "diff", "--staged", "--name-only" }
  table_utils.extend(changed_files, staged_files)
  if vim.fn.len(changed_files) == 0 then
    wrapper_notify("NO changed file!", vim.log.levels.WARN)
    return
  end

  show_menu(server_lines, function(item)
    run_upload_for_many_files(changed_files, decode_line(item.text), config)
  end, function()
    wrapper_notify("Cancel upload", vim.log.levels.WARN)
  end)
end

-- M.upload_files_specified
-- upload specified files where are writed in ${default_upload_filenam}`
-- in project directory
function M.upload_files_specified()
  if -1 == validate_executable_bin() then
    return
  end

  local config = get_config()
  if config == nil then
    return
  end

  local server_lines = {}
  for idx, server in ipairs(config.servers) do
    table.insert(server_lines, Menu.item(encode_line(idx, server)))
  end

  local upload_server_file = vim.loop.cwd() .. "/" .. default_upload_filename
  if vim.fn.filereadable(upload_server_file) == 0 then
    wrapper_notify(string.format("%s is not existed!", default_upload_filename), vim.log.levels.WARN)
    return
  end

  local upload_file_lines = vim.fn.readfile(upload_server_file)
  if vim.fn.len(upload_file_lines) == 0 then
    wrapper_notify(string.format("%s is empty!", default_upload_filename), vim.log.levels.WARN)
    return
  end

  show_menu(server_lines, function(item)
    run_upload_for_many_files(upload_file_lines, decode_line(item.text), config)
  end, function()
    wrapper_notify("Cancel upload", vim.log.levels.WARN)
  end)
end

local const_diff_window_name = "Diff Remote File"

local function diff_file(target, config)
  -- command format: sync-client --addr [remote_host]:[remote_port] \
  --               pull \
  --               --file-mappings [local_file_path]:[remote_file_path]
  --               --host xxx.com
  -- print(target.idx, target.display_name)

  local tmp_local_file_path = "/tmp" .. buf_utils.get_abs_buf_file()
  local remote_file_path = config.target_root_dir .. buf_utils.get_relative_buf_file()

  local cmd = string.format(
    "sync-client --addr %s %s %s pull --file-mappings %s:%s",
    make_addr_chunk(target, config),
    make_host_chunk(target, config),
    make_ssl_chunk(config),
    tmp_local_file_path,
    remote_file_path
  )

  local output = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    wrapper_notify(string.format("%s", output), vim.log.levels.WARN)
  else
    win_utils.diff_vsplit_file(const_diff_window_name, tmp_local_file_path)
  end
end

-- M.diff_current_file
function M.diff_current_file()
  if -1 == validate_executable_bin() then
    return
  end

  local config = get_config()
  if config == nil then
    return
  end

  local lines = {}
  for idx, server in ipairs(config.servers) do
    table.insert(lines, Menu.item(encode_line(idx, server)))
  end

  show_menu(lines, function(item)
    diff_file(decode_line(item.text), config)
  end, function()
    wrapper_notify("Cancel upload", vim.log.levels.WARN)
  end)
end

function M.close_diff()
  win_utils.close_diff_vsplit(const_diff_window_name)
end

-- M.set_server_configs
-- @param server_configs table
function M.set_server_configs(server_configs)
  configs = server_configs
end

return M
