local buf_utils = require "custom.utils.buf"
local table_utils = require "custom.utils.table"

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
--      target_root_dir = "project root name on remote server",  -- note: must endswith '/'
--      servers = {
--        {name = "alias name", host = "1.1.1.1:8080"}
--      }
--   }
-- }

local configs = {
  {
    name = "nvim",
    target_root_dir = "/tmp/test/",
    servers = {
      { name = "mine", host = "127.0.0.1:9091" },
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
  return string.format("%s. %s -> %s", idx, server.name, server.host)
end

local function decode_line(line)
  local chunks = vim.fn.split(line, " ")
  return {
    idx = string.gsub(chunks[1], "[.]", ""),
    name = chunks[2],
    host = chunks[4],
  }
end

local function run_upload(target, config)
  -- command format: sync-client --addr [remote_host]:[remote_port] \
  --               --local-file-path [local_file_path] \
  --               --remote-file-path [remote_file_path]
  -- print(target.idx, target.name, target.host)

  local local_file_path = buf_utils.get_abs_buf_file()
  local remote_file_path = config.target_root_dir .. buf_utils.get_relative_buf_file()
  local cmd = string.format(
    "sync-client --addr %s --local-file-path %s --remote-file-path %s --enable-insecure-ssl",
    target.host,
    local_file_path,
    remote_file_path
  )

  local out_list, err_list = {}, {}
  local job_id = vim.fn.jobstart(cmd, {
    on_stdout = function(_, data)
      for _, line in ipairs(data) do
        if line ~= "" then
          table.insert(out_list, line)
        end
      end
    end,
    on_stderr = function(_, data)
      for _, line in ipairs(data) do
        if line ~= "" then
          table.insert(err_list, line)
        end
      end
    end,
  })
  vim.fn.jobwait { job_id }

  local text = table_utils.join(table_utils.flatten { out_list, err_list }, "\n")
  if vim.fn.len(err_list) == 0 then
    wrapper_notify(text, vim.log.levels.INFO)
  else
    wrapper_notify(text, vim.log.levels.ERROR)
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
  --               ----file-mappings local_path1:remote_path1,local_path2:remote_path2,...
  local project_root_dir = vim.loop.cwd()

  local mappings = {}
  for _, file in ipairs(files) do
    table.insert(mappings, string.format("%s/%s:%s%s", project_root_dir, file, config.target_root_dir, file))
  end

  -- local cmd = string.format(
  --   "sync-client --addr %s --file-mappings %s --enable-insecure-ssl",
  --   target.host,
  --   table.concat(mappings, ",")
  -- )
  local cmd = string.format("sync-client --addr %s --file-mappings %s", target.host, table.concat(mappings, ","))
  print("cmd: " .. cmd)

  local out_list, err_list = {}, {}
  local job_id = vim.fn.jobstart(cmd, {
    on_stdout = function(_, data)
      for _, line in ipairs(data) do
        if line ~= "" then
          table.insert(out_list, line)
        end
      end
    end,
    on_stderr = function(_, data)
      for _, line in ipairs(data) do
        if line ~= "" then
          table.insert(err_list, line)
        end
      end
    end,
  })
  vim.fn.jobwait { job_id }

  local text = table_utils.join(table_utils.flatten { out_list, err_list }, "\n")
  if vim.fn.len(err_list) == 0 then
    wrapper_notify(text, vim.log.levels.INFO)
  else
    wrapper_notify(text, vim.log.levels.ERROR)
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

-- M.set_server_configs
-- @param server_configs table
function M.set_server_configs(server_configs)
  configs = server_configs
end

return M
