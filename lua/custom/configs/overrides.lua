local M = {}

M.treesitter = {
  ensure_installed = {
    "vim",
    "lua",
    "javascript",
    "c",
    "go",
    "python",
    "rust",
    "vimdoc",
  },
  indent = {
    -- enable = false,
    disable = {
      "rust",
    },
  },
}

M.mason = {
  ensure_installed = {
    -- lua stuff
    "lua-language-server",
    "stylua",

    --  custom
    "pyright",
    "gopls",
    "rust-analyzer",
  },
}

-- git support in nvimtree
M.nvimtree = {
  git = {
    enable = true,
  },

  renderer = {
    highlight_git = true,
    icons = {
      show = {
        git = true,
      },
    },
  },

  actions = {
    open_file = {
      resize_window = false,
    },
  },

  filters = {
    custom = { ".git" },
  },
}

M.telescope = {
  defaults = {
    initial_mode = "insert",
    selection_strategy = "reset",
    layout_strategy = "bottom_pane",
    layout_config = {
      flex = {
        width = 0.9,
      },
      bottom_pane = {
        prompt_position = "top",
      },
      horizontal = {
        prompt_position = "bottom",
        preview_width = 0.5,
        results_width = 0.8,
      },
      vertical = {
        mirror = false,
      },
      height = 0.70,
      preview_cutoff = 120,
    },
    borderchars = {
      prompt = { "─", " ", "─", " ", "╭", "╮", "╯", "╰" },
      results = { "─", "│", "─", "│", " ", "╮", "╯", "╰" },
      preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    },
  },
}

M.whichkey = {
  window = {
    border = "double",
  },
}

M.indent_blankline = {
  show_current_context_start = false,
}

M.nvterm = {
  terminals = {
    shell = vim.o.shell,
    list = {},
    type_opts = {
      float = {
        relative = "editor",
        row = 0.05,
        col = 0.1,
        width = 0.8,
        height = 0.8,
        border = "single",
      },
      horizontal = { location = "rightbelow", split_ratio = 0.3 },
      vertical = { location = "rightbelow", split_ratio = 0.5 },
    },
  },
  behavior = {
    autoclose_on_quit = {
      enabled = false,
      confirm = true,
    },
    close_on_exit = true,
    auto_insert = true,
  },
}

return M
