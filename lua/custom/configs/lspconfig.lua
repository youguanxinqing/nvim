local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

-- fix: attempt to index field 'semanticTokensProvider' (a nil value)
-- refs: https://github.com/neovim/nvim-lspconfig/issues/2542#issuecomment-1547019213
local on_init = function(client, initialization_result)
  local _ = initialization_result
  if client.server_capabilities then
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.semanticTokensProvider = false -- turn off semantic tokens
  end
end

-- Function to get pyenv Python path
local function get_pyenv_python_path()
  -- First, check for .venv in current directory or project root
  local cwd = vim.fn.getcwd()
  local venv_python = cwd .. "/.venv/bin/python"

  if vim.fn.filereadable(venv_python) == 1 then
    return venv_python
  end

  -- Check for common subdirectory patterns (e.g., docling/.venv, backend/.venv)
  -- Look for pyrightconfig.json to determine venv location
  local pyright_config = cwd .. "/pyrightconfig.json"
  if vim.fn.filereadable(pyright_config) == 1 then
    local config_content = vim.fn.readfile(pyright_config)
    local config_json = vim.fn.json_decode(table.concat(config_content, "\n"))

    if config_json.venv and config_json.venv ~= "" then
      local venv_from_config = cwd .. "/" .. config_json.venv .. "/bin/python"
      if vim.fn.filereadable(venv_from_config) == 1 then
        return venv_from_config
      end
    end
  end

  -- Try to get Python path from pyenv
  local pyenv_python = vim.fn.system "pyenv which python 2>/dev/null"
  if vim.v.shell_error == 0 and pyenv_python ~= "" then
    return vim.fn.trim(pyenv_python)
  end

  -- Fallback to system Python
  local system_python = vim.fn.exepath "python"
  if system_python ~= "" then
    return system_python
  end

  -- Last resort
  return "python"
end

-- Function to get venv path (for pyright to find virtual environments)
local function get_pyenv_versions_path()
  -- First check if there's a .venv in current directory
  local cwd = vim.fn.getcwd()
  if vim.fn.isdirectory(cwd .. "/.venv") == 1 then
    return cwd
  end

  -- Otherwise use pyenv versions directory
  local pyenv_root = vim.fn.expand "~/.pyenv"
  local versions_path = pyenv_root .. "/versions"

  if vim.fn.isdirectory(versions_path) == 1 then
    return versions_path
  end

  return ""
end

-- Configure lua_ls using new vim.lsp.config API
vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
  on_init = on_init,
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "lua" },
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
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = "LuaJIT",
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { "vim" },
        disbale = {
          "missing-fields",
        },
        severity = {
          missingFields = "Error!",
        },
      },
      workspace = {
        library = {
          [vim.fn.expand "$VIMRUNTIME/lua"] = true,
          [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
          [vim.fn.stdpath "data" .. "/lazy/extensions/nvchad_types"] = true,
          [vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy"] = true,
        },
        maxPreload = 100000,
        preloadFileSize = 10000,
      },
    },
  },
})

-- Enable lua_ls
vim.lsp.enable "lua_ls"

local function on_attach_for_rust(client, bufnr)
  on_attach(client, bufnr)

  if vim.lsp.inlay_hint then
    vim.lsp.inlay_hint.enable(true, { 0 })
  end
end

-- Configure rust_analyzer using new vim.lsp.config API
vim.lsp.config("rust_analyzer", {
  cmd = { "rust-analyzer" },
  on_init = on_init,
  on_attach = on_attach_for_rust,
  capabilities = capabilities,
  filetypes = { "rust" },
  root_markers = { "Cargo.toml" },
})

-- Enable rust_analyzer
vim.lsp.enable "rust_analyzer"

-- Configure gopls using new vim.lsp.config API
vim.lsp.config("gopls", {
  cmd = { "gopls" },
  on_init = on_init,
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = { "go.mod" },
  -- cmd_env = { GOFLAGS = "-tags=tag1,tag2" },
})

-- Enable gopls
vim.lsp.enable "gopls"

-- Configure pyright using new vim.lsp.config API
vim.lsp.config("pyright", {
  cmd = { "pyright-langserver", "--stdio" },
  on_init = on_init,
  on_attach = on_attach,
  capabilities = capabilities,
  root_markers = {
    "pyrightconfig.json",
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "Pipfile",
    ".git",
  },
  single_file_support = true,
  filetypes = { "python" },
  settings = {
    python = {
      pythonPath = get_pyenv_python_path(),
      venvPath = get_pyenv_versions_path(),
      analysis = {
        diagnosticMode = "openFilesOnly",
        typeCheckingMode = "basic",
        diagnosticSeverityOverrides = {
          reportGeneralTypeIssues = "none",
        },
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      },
    },
  },
})

-- Enable pyright
vim.lsp.enable "pyright"

-- Copilot is handled by zbirenbaum/copilot.lua plugin, not via LSP
-- Removed duplicate copilot LSP config to avoid conflicts and improve performance
