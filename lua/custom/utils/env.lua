local M = {}

local default_configs = {
  pyenv_path = "~/.pyenv/versions/",
  version_file = ".python-version",
}

local function convert_type(typ, value)
  if typ == "string" then
    return vim.fn.join(value, " ")
  end
  return value
end

--- M.with_pyenv
--- @param cmd table|string
--- @return table|string
function M.with_pyenv(cmd)
  local root_dir = vim.loop.cwd()
  local file = root_dir .. "/" .. default_configs.version_file

  if vim.fn.filereadable(file) == 0 then
    return cmd
  end

  local version = vim.fn.readfile(file, "b", 1)[1]
  if version == "" then
    return cmd
  end
  local py_with_pyenv = vim.fn.expand(default_configs.pyenv_path .. version .. "/bin/python")

  local typ = type(cmd)
  if typ == "string" then
    cmd = vim.fn.split(cmd, " ", true)
  end

  local new_cmd = {}
  for _, item in ipairs(cmd) do
    if string.match(item, "^python") then
      table.insert(new_cmd, py_with_pyenv)
    else
      table.insert(new_cmd, item)
    end
  end

  return convert_type(typ, new_cmd)
end

return M
