local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"

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

-- Function to get pyenv versions directory
local function get_pyenv_versions_path()
  local pyenv_root = vim.fn.expand "~/.pyenv"
  local versions_path = pyenv_root .. "/versions"

  if vim.fn.isdirectory(versions_path) == 1 then
    return versions_path
  end

  return ""
end

lspconfig.lua_ls.setup {
  on_init = on_init,
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "lua" },
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
}

local function on_attach_for_rust(client, bufnr)
  on_attach(client, bufnr)

  if vim.lsp.inlay_hint then
    vim.lsp.inlay_hint.enable(true, { 0 })
  end
end

lspconfig.rust_analyzer.setup {
  on_init = on_init,
  on_attach = on_attach_for_rust,
  capabilities = capabilities,
  filetypes = { "rust" },
  root = lspconfig.util.root_pattern "Cargo.toml",
}

lspconfig.gopls.setup {
  on_init = on_init,
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root = lspconfig.util.root_pattern "go.mod",
  -- cmd_env = { GOFLAGS = "-tags=tag1,tag2" },
}

lspconfig.pyright.setup {
  on_init = on_init,
  on_attach = on_attach,
  capabilities = capabilities,
  root_dir = function(fname)
    local default_config = require("lspconfig.configs.pyright").default_config
    return default_config.root_dir(fname) or require("lspconfig.util").find_git_ancestor(fname)
  end,
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
}
