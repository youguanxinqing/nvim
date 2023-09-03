---@type MappingsTable
local M = {}

M.general = {
	n = {
		["<C-c>"] = { "<Esc>", "exit insert mode", opts = { nowait = true } },
		-- [";"] = { ":", "enter command mode", opts = { nowait = true } },
	},
	i = {
		["<C-c>"] = { "<Esc>", "exit insert mode", opts = { nowait = true } },
	},
}

M.comment = {
	plugin = true,

	-- toggle comment in both modes
	n = {
		["gcc"] = {
			function()
				require("Comment.api").toggle.linewise.current()
			end,
			"toggle comment",
		},
		["<Leader>qa"] = {
			":qa<CR>",
			"quit all",
		},
	},

	v = {
		["gc"] = {
			"<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
			"toggle comment",
		},
	},
}

M.telescope = {
	plugin = true,

	n = {
		-- find
		["<C-f>"] = { "<cmd> Telescope current_buffer_fuzzy_find <CR>", "find in current buffer" },
	},
}

M.tabufline = {
	plugin = true,

	n = {
		-- close all buffers
		["<leader>ax"] = {
			function()
				require("nvchad_ui.tabufline").closeOtherBufs()
			end,
			"close all buffer except current buffer",
		},
	},
}

M.bookmark = {
	plugin = true,

	n = {
		["<leader>ma"] = { "<cmd> BookmarkToggle <CR>", "bookmark toggle" },
		["<leader>ml"] = { "<cmd> BookmarkList <CR>", "list bookmarks" },
	},
}

M.winpick = {
	-- plugin = true,

	n = {
		["<leader>ws"] = { "<cmd> lua require('custom.configs.winpick').select() <CR>", "select window" },
	},
}

-- require("core.utils").load_mappings("bookmark")

-- more keybinds!

return M
