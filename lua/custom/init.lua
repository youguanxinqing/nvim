-- local autocmd = vim.api.nvim_create_autocmd

-- Auto resize panes when resizing nvim window
-- autocmd("VimResized", {
--   pattern = "*",
--   command = "tabdo wincmd =",
-- })

-- vim.o.cmdheight = 1
-- vim.o.scrolloff = 1
--

-- vim.api.nvim_create_autocmd({ "BufAdd", "BufEnter", "tabnew" }, {
--   callback = function()
--     vim.t.bufs = vim.tbl_filter(function(bufnr)
--       return vim.api.nvim_buf_get_option(bufnr, "modified")
--     end, vim.t.bufs)
--   end,
-- })

-- vim.o.winbar = "%{%v:lua.require'custom.configs.nvim-navic'.get_winbar()%}"
--
--
--

-- https://snippet-generator.app/
vim.g.vscode_snippets_path = "./lua/custom/snippets"

-- vim.cmd command!
vim.api.nvim_create_user_command(
  "UploadFile",
  'lua require("custom.configs.upload-server").upload_server()',
  { bang = true }
)
vim.api.nvim_create_user_command(
  "UploadFilesChanged",
  'lua require("custom.configs.upload-server").upload_files_changed()',
  { bang = true }
)
vim.api.nvim_create_user_command(
  "UploadFilesSpecified",
  'lua require("custom.configs.upload-server").upload_files_specified()',
  { bang = true }
)
vim.api.nvim_create_user_command(
  "DiffCurrentFile",
  'lua require("custom.configs.upload-server").diff_current_file()',
  { bang = true }
)
vim.api.nvim_create_user_command(
  "CloseDiff",
  'lua require("custom.configs.upload-server").close_diff()',
  { bang = true }
)
vim.api.nvim_create_user_command("GitHistory", "Telescope git_bcommits", { bang = true })
vim.api.nvim_create_user_command("GitBlame", "Gitsigns blame", { bang = true })
vim.api.nvim_create_user_command("GitToggleLineBlame", "Gitsigns toggle_current_line_blame", { bang = true })
vim.api.nvim_create_user_command("GitDiffThis", "Gitsigns diffthis", { bang = true })

-- vim.cmd autocmd for command!
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python" },
  callback = function()
    vim.api.nvim_create_user_command(
      "PyRun",
      'lua require("custom.configs.run-anything").run_current_script_for_py()',
      { bang = true }
    )
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go" },
  callback = function()
    vim.api.nvim_create_user_command(
      "GoGenEnumToString",
      'lua require("custom.configs.gen-go-code").enum_to_string()',
      { bang = true }
    )
    vim.api.nvim_create_user_command(
      "RunUnitTest",
      'lua require("custom.configs.run-anything").run_unit_test_for_go()',
      { bang = true }
    )
    vim.api.nvim_create_user_command(
      "GoRunPackageTests",
      'lua require("custom.configs.run-anything").run_file_tests_for_go()',
      { bang = true }
    )
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua" },
  callback = function()
    vim.api.nvim_create_user_command(
      "RunUnitTest",
      'lua require("custom.configs.run-anything").run_unit_test_for_lua()',
      { bang = true }
    )
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "rust" },
  callback = function()
    vim.api.nvim_create_user_command(
      "RunUnitTest",
      'lua require("custom.configs.run-anything").run_unit_test_for_rust()',
      { bang = true }
    )
  end,
})

if vim.g.neovide then
  require "custom.neovide"
end
