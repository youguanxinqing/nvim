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

vim.cmd [[
command! GenGoEnumToString lua require("custom.configs.gen-go-code").enum_to_string()

command! UncolorAllWords lua require("interestingwords").UncolorAllWords()
]]
