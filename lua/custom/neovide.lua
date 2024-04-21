vim.g.neovide_scale_factor = 1.1
vim.g.neovide_transparency = 0.96
vim.g.neovide_window_blurred = true
-- FIX: failed to display on windows wsl
vim.o.guifont = "JetBrainsMono Nerd Font"

vim.keymap.set("n", "<S-Insert>", '"+p')
vim.keymap.set("i", "<S-Insert>", "<C-R>+")
vim.keymap.set("c", "<S-Insert>", "<C-R>+")
vim.keymap.set("t", "<S-Insert>", '<C-\\><C-o>"+p', { noremap = true, silent = true })
