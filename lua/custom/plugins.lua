local overrides = require "custom.configs.overrides"

-- ---@type NvPluginSpec[]
local plugins = {

  -- Override plugin definition options

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- format & linting
      {
        "jose-elias-alvarez/null-ls.nvim",
        config = function()
          require "custom.configs.null-ls"
        end,
      },
    },
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end, -- Override to setup mason-lspconfig
  },

  -- override plugin configs
  {
    "williamboman/mason.nvim",
    opts = overrides.mason,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = overrides.treesitter,
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = overrides.nvimtree,
  },

  {
    "NvChad/nvterm",
    opts = overrides.nvterm,
  },

  {
    "nvim-telescope/telescope.nvim",
    opts = overrides.telescope,
    config = function(_, opts)
      local telescope = require "telescope"
      telescope.setup(opts)
      -- load extensions
      for _, ext in ipairs(opts.extensions_list) do
        telescope.load_extension(ext)
      end

      require "custom.configs.telescope.git_bcommits"
    end,
  },
  {
    "folke/which-key.nvim",
    opts = overrides.whichkey,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    opts = overrides.indent_blankline,
  },

  -- Install a plugin
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup()
    end,
  },

  -- To make a plugin not be loaded
  -- {
  --   "NvChad/nvim-colorizer.lua",
  --   enabled = false
  -- },

  -- All NvChad plugins are lazy-loaded by default
  -- For a plugin to be loaded, you will need to set either `ft`, `cmd`, `keys`, `event`, or set `lazy = false`
  -- If you want a plugin to load on startup, add `lazy = false` to a plugin spec, for example
  -- {
  --   "mg979/vim-visual-multi",
  --   lazy = false,
  -- }

  -- search words
  {
    "ggandor/flit.nvim",
    event = "VeryLazy",
    -- lazy = false,
    dependencies = {
      {
        "ggandor/leap.nvim",
      },
    },
    config = function()
      require "custom.configs.flit"
    end,
  },
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      -- 'Shatur/neovim-session-manager',
    },
    opts = function()
      local handlers = require "custom.configs.alpha-nvim"

      local dashboard = require "alpha.themes.dashboard"
      return handlers.dashboard_handler(dashboard)
    end,
    config = function(_, dashboard)
      require("alpha").setup(dashboard.opts)
    end,
  },
  {
    "rmagatti/auto-session",
    dependencies = {
      "zwhitchcox/auto-session-nvim-tree",
    },
    lazy = false,
    config = function()
      require "custom.configs.auto-session"
    end,
  },
  {
    "simrat39/symbols-outline.nvim",
    cmd = "SymbolsOutline",
    config = function()
      require "custom.configs.symbols-outline"
    end,
  },
  {
    "youguanxinqing/bookmark.nvim",
    branch = "youguan",
    lazy = false,
    cmd = { "BookmarkToggle", "BookmarkList", "FilemarkToggle", "FilemarkList" },
    dependencies = {
      "kkharji/sqlite.lua",
    },
    init = function()
      require("core.utils").load_mappings "bookmark"
    end,
    config = function()
      local icons = require "custom.configs.icons"
      require("bookmark").setup {
        sign = icons.ui.BookMark,
        highlight = "Function",
        file_sign = "󱡅",
        file_highlight = "Function",
      }
      require("telescope").load_extension "bookmark"
    end,
  },
  {
    "Mr-LLLLL/interestingwords.nvim",
    keys = { "<leader>k" },
    config = function()
      require("interestingwords").setup {
        colors = { "#aeee00", "#ff0000", "#C4B0FF", "#FFABAB", "#FFEF82", "#62CDFF" },
        search_count = true,
        navigation = true,
        -- search_key = "<leader>m",
        -- cancel_search_key = "<leader>M",
        color_key = "<leader>k",
        cancel_color_key = "<leader>K",
      }
    end,
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    config = function()
      require("flash").setup {
        modes = {
          char = {
            enabled = false,
          },
          search = {
            enabled = false,
          },
        },
      }
    end,
    keys = {
      {
        "<leader>s",
        mode = { "n" },
        function()
          require("flash").jump()
        end,
        desc = "Toggle Flash Search",
      },
    },
  },
  -- {
  -- 	"utilyre/barbecue.nvim",
  -- 	event = "VeryLazy",
  -- 	name = "barbecue",
  -- 	version = "*",
  -- 	dependencies = {
  -- 		"SmiteshP/nvim-navic",
  -- 		"nvim-tree/nvim-web-devicons", -- optional dependency
  -- 	},
  -- 	config = function()
  -- 		require("barbecue").setup({
  -- 			attach_navic = true,
  -- 		})
  -- 	end,
  -- },
  -- {
  -- 	"lvimuser/lsp-inlayhints.nvim",
  -- 	event = "VeryLazy",
  -- 	opts = function()
  -- 		return require("custom.configs.lsp-inlayhints").opts
  -- 	end,
  -- 	config = function(_, opts)
  -- 		require("custom.configs.lsp-inlayhints").setup(opts)
  -- 	end,
  -- },
  {
    "theniceboy/nvim-deus",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd [[colorscheme deus]]
    end,
  },
  {
    "youguanxinqing/smartcolumn.nvim",
    event = "VeryLazy",
    opts = {
      colorcolumn = "120",
      disabled_filetypes = { "help", "text", "markdown" },
      custom_colorcolumn = {},
      scope = "file",
    },
  },
  {
    "princejoogie/dir-telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    cmd = { "GrepInDirectory", "FileInDirectory" },
    config = function()
      require("custom.configs.dir-telescope").setup()
    end,
  },
  {
    "gbrlsnchs/winpick.nvim",
    event = "VeryLazy",
    config = function()
      require("custom.configs.winpick").setup()
    end,
  },

  {
    "nvim-treesitter/nvim-tree-docs",
    config = function()
      require("nvim-treesitter/nvim-tree-docs").setup {
        tree_docs = { enable = true },
      }
    end,
  },

  {
    "MunifTanjim/nui.nvim",
  },
  {
    "rcarriga/nvim-notify",
  },
}

return plugins
