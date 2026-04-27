local present, leap = pcall(require, "leap")

if not present then
  return
end

-- Equivalent of flit's f/F/t/T with labeled_modes = "nvo" and multiline = true
local function flit_opts(key_specific_args)
  local common_args = {
    inputlen = 1,
    inclusive = true,
    opts = {
      labels = "",
      equivalence_classes = {
        " \t\r\n",
        "aA", "bB", "cC", "dD", "eE", "fF", "gG", "hH",
        "iI", "jJ", "kK", "lL", "mM", "nN", "oO", "pP",
        "qQ", "rR", "sS", "tT", "uU", "vV", "wW", "xX",
        "yY", "zZ",
      },
    },
  }
  return vim.tbl_deep_extend("keep", common_args, key_specific_args)
end

for key, args in pairs {
  f = {},
  F = { backward = true },
  t = { offset = -1 },
  T = { backward = true, offset = 1 },
} do
  vim.keymap.set({ "n", "x", "o" }, key, function()
    leap.leap(flit_opts(args))
  end)
end

-- Backdrop highlight
require("leap.user").set_backdrop_highlight "LeapBackdrop"
vim.api.nvim_set_hl(0, "LeapBackdrop", { link = "Comment" })

-- Labels
leap.opts.safe_labels = {
  "n", "u", "t", "/",
  "S", "F", "N", "L", "H", "M", "U", "G", "T", "?", "Z",
}

leap.opts.labels = {
  "n", "j", "k", "l", "h", "o", "d", "w", "e", "m",
  "b", "u", "y", "v", "r", "g", "t", "c", "x", "/", "z",
  "S", "F", "N", "J", "K", "L", "H", "O", "D", "W", "E",
  "M", "B", "U", "Y", "V", "R", "G", "T", "C", "X", "?", "Z",
}

-- Case sensitive (ignorecase = false)
leap.opts.vim_opts = { ["go.ignorecase"] = false }
