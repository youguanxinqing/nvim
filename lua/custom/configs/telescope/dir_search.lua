local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local make_entry = require "telescope.make_entry"
local conf = require("telescope.config").values
local sorters = require "telescope.sorters"

local buf_utils = require "custom.utils.buf"

local flatten = vim.tbl_flatten

local M = {}

-- M.search_in_cur_dir search words in current directory
function M.search_in_cur_dir(opts)
  opts = opts or {}

  local search_dirs = { buf_utils.get_cur_buf_dir() }
  local vimgrep_arguments = opts.vimgrep_arguments or conf.vimgrep_arguments
  local args = flatten { vimgrep_arguments }

  local live_grepper = finders.new_job(function(prompt)
    if not prompt then
      prompt = ""
    end

    return flatten { args, "--", prompt, search_dirs }
  end, opts.entry_maker or make_entry.gen_from_vimgrep(opts), opts.max_results, opts.cwd)

  pickers
    .new(opts, {
      prompt_title = "Search in -> " .. buf_utils.get_cur_buf_dir(),
      finder = live_grepper,
      previewer = conf.grep_previewer(opts),
      sorter = sorters.highlighter_only(opts),
    })
    :find()
end

return M
