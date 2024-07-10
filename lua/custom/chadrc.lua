---@type ChadrcConfig
local M = {}

-- Path to overriding theme and highlights files
local highlights = require "custom.highlights"

M.ui = {
  theme = "everforest-guan",
  theme_toggle = { "everforest-guan", "one_light" },

  hl_override = highlights.override,
  hl_add = highlights.add,
}

M.plugins = "custom.plugins"

-- check core.mappings for table structure
M.mappings = require "custom.mappings"

-- customize config
vim.wo.wrap = false
vim.cmd [[
set clipboard=unnamed,unnamedplus

hi ColorColumn ctermbg=0 guibg=#242a32
hi WinSeparator ctermbg=0 guifg=#555555
hi GitSignsCurrentLineBlame ctermbg=0 guifg=#bbbbbb

autocmd BufRead * autocmd FileType <buffer> ++once
  \ if &ft !~# 'commit\|rebase' && line("'\"") > 1 && line("'\"") <= line("$") | exe 'normal! g`"' | endif
]]

return M
