local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local make_entry = require "telescope.make_entry"
local conf = require("telescope.config").values
local sorters = require "telescope.sorters"

local buf_utils = require "custom.utils.buf"
local string_uitils = require "custom.utils.string"
local table_uitils = require "custom.utils.table"

local flatten = vim.tbl_flatten

local M = {}

-- M.search_in_current_dir search words in current directory
function M.search_in_current_dir(opts)
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
      prompt_title = "Search In -> " .. buf_utils.get_cur_buf_dir(),
      finder = live_grepper,
      previewer = conf.grep_previewer(opts),
      sorter = sorters.highlighter_only(opts),
    })
    :find()
end

function M.search_in_listed_buffers(opts)
  opts = opts or {}

  local listed_buffers = vim.tbl_filter(function(bufno)
    local info = vim.fn.getbufinfo(bufno)[1]
    if info.listed ~= 1 then
      return false
    end
    return true
  end, vim.api.nvim_list_bufs())

  local search_files = vim.tbl_map(function(bufno)
    return vim.api.nvim_buf_get_name(bufno)
  end, listed_buffers)

  local vimgrep_arguments = opts.vimgrep_arguments or conf.vimgrep_arguments
  local args = flatten { vimgrep_arguments }

  local live_grepper = finders.new_job(function(prompt)
    if not prompt then
      prompt = ""
    end

    return flatten { args, "--", prompt, search_files }
  end, opts.entry_maker or make_entry.gen_from_vimgrep(opts), opts.max_results, opts.cwd)

  pickers
    .new(opts, {
      prompt_title = "Search In Listed Buffers",
      finder = live_grepper,
      previewer = conf.grep_previewer(opts),
      sorter = sorters.highlighter_only(opts),
    })
    :find()
end

function M.search_in_current_buffer(opts)
  opts = opts or {}

  local search_files = { buf_utils.get_abs_buf_file() }

  local vimgrep_arguments = opts.vimgrep_arguments or conf.vimgrep_arguments
  local args = flatten { vimgrep_arguments }

  local live_grepper = finders.new_job(function(prompt)
    if not prompt then
      prompt = ""
    end

    return flatten { args, "--", prompt, search_files }
  end, opts.entry_maker or make_entry.gen_from_vimgrep(opts), opts.max_results, opts.cwd)

  pickers
    .new(opts, {
      prompt_title = "Search In Current Buffer",
      finder = live_grepper,
      previewer = conf.grep_previewer(opts),
      sorter = sorters.highlighter_only(opts),
    })
    :find()
end

function M.find_files_from_here(opts)
  opts = opts or {}

  local files_from_here = buf_utils.get_cur_buf_dir()

  local live_grepper = finders.new_job(function(prompt)
    prompt = vim.fn.trim(prompt)

    local dir = nil
    if string.match(prompt, "%s+") ~= nil then
      local chunks = string_uitils.splitn(prompt, " ", 2)
      if vim.fn.len(chunks) >= 2 then
        dir, prompt = vim.fn.trim(chunks[1]), vim.fn.trim(chunks[2])
      else
        dir, prompt = prompt, ""
      end
    else
      dir, prompt = prompt, ""
    end

    local is_dir = vim.fn.isdirectory(dir)
    if is_dir == 0 then
      local chunks = string_uitils.split(dir, "/")
      prompt = chunks[vim.fn.len(chunks)]
      chunks[vim.fn.len(chunks)] = ""
      dir = table_uitils.join(chunks, "/")
    end

    local notice = string.format("dir:%s,prompt:%s", dir, prompt)
    print(notice)
    return flatten { { "rg", "--files", "--color", "never" }, "--", prompt, dir }
  end, opts.entry_maker or make_entry.gen_from_file(opts), opts.max_results, opts.cwd)

  pickers
    .new(opts, {
      prompt_title = "Find Files From Here",
      __locations_input = true,
      finder = live_grepper,
      previewer = conf.grep_previewer(opts),
      sorter = conf.file_sorter(opts),
      default_text = files_from_here,
    })
    :find()
end

return M
