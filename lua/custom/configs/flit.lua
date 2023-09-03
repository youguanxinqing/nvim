local present, flit = pcall(require, "flit")

if not present then
	return
end

flit.setup({
	keys = { f = "f", F = "F", t = "t", T = "T" },
	labeled_modes = "nvo",
	-- A string like "nv", "nvo", "o", etc.
	-- labeled_modes = "nvo",
	multiline = true,
	-- Like `leap`s similar argument (call-specific overrides).
	-- E.g.: opts = { equivalence_classes = {} }
	-- opts = { labeled_modes = "nx" },
})

vim.api.nvim_set_hl(0, "LeapBackdrop", { link = "Comment" })

local present2, leap = pcall(require, "leap")

if not present2 then
	return
end

leap.opts.safe_labels = {
	-- "s",
	-- "f",
	"n",
	"u",
	"t",
	"/",
	"S",
	"F",
	"N",
	"L",
	"H",
	"M",
	"U",
	"G",
	"T",
	"?",
	"Z",
}

leap.opts.labels = {
	-- "s",
	-- "f",
	"n",
	"j",
	"k",
	"l",
	"h",
	"o",
	"d",
	"w",
	"e",
	"m",
	"b",
	"u",
	"y",
	"v",
	"r",
	"g",
	"t",
	"c",
	"x",
	"/",
	"z",
	"S",
	"F",
	"N",
	"J",
	"K",
	"L",
	"H",
	"O",
	"D",
	"W",
	"E",
	"M",
	"B",
	"U",
	"Y",
	"V",
	"R",
	"G",
	"T",
	"C",
	"X",
	"?",
	"Z",
}
