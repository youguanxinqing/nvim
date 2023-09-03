local present, _ = pcall(require, "alpha")

if not present then
	return
end

-- dashboard image
local function dashboard_handler(dashboard)
	local logo = {
		-- [[    _______  __    __       ___      .__   __.  ]],
		-- [[   /  _____||  |  |  |     /   \     |  \ |  |  ]],
		-- [[  |  |  __  |  |  |  |    /  ^  \    |   \|  |  ]],
		-- [[  |  | |_ | |  |  |  |   /  /_\  \   |  . `  |  ]],
		-- [[  |  |__| | |  `--'  |  /  _____  \  |  |\   |  ]],
		-- [[   \______|  \______/  /__/     \__\ |__| \__|  ]],

		[[                                   ]],
		[[          ▀████▀▄▄              ▄█ ]],
		[[            █▀    ▀▀▄▄▄▄▄    ▄▄▀▀█ ]],
		[[    ▄        █          ▀▀▀▀▄  ▄▀  ]],
		[[   ▄▀ ▀▄      ▀▄              ▀▄▀  ]],
		[[  ▄▀    █     █▀   ▄█▀▄      ▄█    ]],
		[[  ▀▄     ▀▄  █     ▀██▀     ██▄█   ]],
		[[   ▀▄    ▄▀ █   ▄██▄   ▄  ▄  ▀▀ █  ]],
		[[    █  ▄▀  █    ▀██▀    ▀▀ ▀▀  ▄▀  ]],
		[[   █   █  █      ▄▄           ▄▀   by guan ]],

		-- [[      .'`'.'`'.       ]],
		-- [[  .''.`.  :  .`.''.   ]],
		-- [[  '.    '. .'    .'   ]],
		-- [[  .```  .' '.  ```.   ]],
		-- [[  '..',`  :  `,'..'   ]],
		-- [[       `-'`'-`))      ]],
		-- [[              ((      ]],
		-- [[               \|     ]],
	}

	dashboard.section.buttons.val = {
		dashboard.button("<leader>ff", "  Find file", ":Telescope find_files <CR>"),
		dashboard.button("<leader>fo", "  Recent Files", ":Telescope oldfiles <CR>"),
		dashboard.button("<leader>fw", "  Find Word", ":Telescope live_grep <CR>"),
		dashboard.button("<leader>th", "  Themes", ":Telescope themes"),
		dashboard.button("<leader>ch", "  Mappings", ":NvCheatsheet"),
		dashboard.button("<leader>qa", "  Quit Neovim", ":qa<CR>"),
	}

	dashboard.section.header.val = logo
	dashboard.section.footer.val = "Don't mind not knowing."

	return dashboard
end

-- export table
return {
	dashboard_handler = dashboard_handler,
}
