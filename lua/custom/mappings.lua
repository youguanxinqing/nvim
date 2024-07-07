---@type MappingsTable
local M = {}

M.disabled = {
  n = {
    ["<leader>b"] = "",
    ["<C-s>"] = "",
  },
}

M.general = {
  n = {
    ["<C-c>"] = { "<Esc>", "exit insert mode", opts = { nowait = true } },
    -- [";"] = { ":", "enter command mode", opts = { nowait = true } },

    -- buffer operations
    ["<Leader>bp"] = {
      function()
        require("custom.configs.where-is").copy_cur_buffer_abs_path()
      end,
      "copy current buffer abs path",
    },
    ["<leader>bn"] = { "<cmd> enew <CR>", "New buffer" },

    -- search
    ["<Leader>fd"] = {
      function()
        require("custom.configs.telescope.search").search_in_current_dir()
      end,
      "search in current directory",
    },
    ["<Leader>sb"] = {
      function()
        require("custom.configs.telescope.search").search_in_listed_buffers()
      end,
      "search in listed buffers",
    },
    ["<leader>ss"] = {
      function()
        require("custom.configs.telescope.search").search_in_current_buffer()
      end,
      "search in current buffer",
    },
    ["<leader><Space>"] = {
      function()
        require("custom.configs.telescope.search").find_files_from_here()
      end,
      "find files from here",
    },

    ["<A-x>"] = { ":", "enter command line mode" },

    -- toggle todo list
    ["<Leader>tt"] = {
      function()
        require("custom.configs.todo-list").toggle_todo_list()
      end,
      "toggle todo list",
    },

    -- windows
    ["<Leader>wo"] = {
      function()
        require("custom.configs.window").enlargen()
      end,
      "Enlarge current window",
    },
    ["<Leader>ww"] = {
      function()
        require("custom.configs.window").swap_windows()
      end,
      "Swith window",
    },
    ["<Leader>wn"] = {
      function()
        require("custom.configs.window").normalize()
      end,
      "Normalize window size",
    },
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
        require("nvchad.tabufline").closeOtherBufs()
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
