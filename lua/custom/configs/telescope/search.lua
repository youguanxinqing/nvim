local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local make_entry = require "telescope.make_entry"
local conf = require("telescope.config").values
local sorters = require "telescope.sorters"
local global_state = require "telescope.state"

local buf_utils = require "custom.utils.buf"
local table_uitils = require "custom.utils.table"

local flatten = table_uitils.flatten

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

local FIND_FILES_PROMPT_KEY = "find-files-prompt"

local function create_file_or_dir()
  local path = global_state.get_global_key(FIND_FILES_PROMPT_KEY)
  if path == nil or path == "" or vim.uv.fs_stat(path) ~= nil then
    return
  end

  local y_or_n = vim.fn.input(string.format("'%s' is not existed, would you create it? y/N: ", path))
  y_or_n = string.lower(vim.fn.trim(y_or_n))
  if y_or_n ~= "y" then
    return
  end

  -- create directory if endswith '/' character
  -- otherwise create file
  if string.sub(path, -1) == "/" then
    require("custom.utils.file").recursive_create_directory(path)
  else
    require("custom.utils.file").recursive_create_file(path)
  end

  print "create ok!"
end

--- M.dir_of_prompt returns the directory part of the prompt, i.e. everything up
--- to the last "/". The tail is left to the fuzzy sorter.
--- @param prompt string
--- @return string
function M.dir_of_prompt(prompt)
  return vim.fs.normalize(string.match(prompt, "^(.*/)") or "./")
end

function M.find_files_from_here(opts)
  opts = opts or {}

  -- absolute dir of the buffer, shortened to a cwd-relative one when possible.
  -- ponytail: fnamemodify keeps this correct for buffers outside cwd, where the
  -- old hand-rolled relative path silently lost its leading "/" and matched nothing.
  local here = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p:h")
  if vim.fn.isdirectory(here) == 0 then
    here = vim.uv.cwd()
  end

  local live_grepper = finders.new_job(function(prompt)
    prompt = vim.fn.trim(prompt or "")
    global_state.set_global_key(FIND_FILES_PROMPT_KEY, prompt)

    local dir = M.dir_of_prompt(prompt)
    if vim.fn.isdirectory(dir) == 0 then
      return nil
    end

    return { "rg", "--files", "--hidden", "--color", "never", "--", dir }
  end, opts.entry_maker or make_entry.gen_from_file(opts), opts.max_results, opts.cwd)

  pickers
    .new(opts, {
      prompt_title = "Find Files From Here",
      __locations_input = true,
      finder = live_grepper,
      previewer = conf.file_previewer(opts),
      sorter = conf.file_sorter(opts),
      default_text = vim.fn.fnamemodify(here, ":.") .. "/",
      attach_mappings = function(_, keymaps)
        keymaps({ "i", "n" }, "<c-a>", create_file_or_dir)
        return true
      end,
    })
    :find()
end

local function test_dir_of_prompt()
  local cases = {
    { "/a/b/c/", "/a/b/c" },
    { "/a/b/c/SKI", "/a/b/c" },
    { "sub/dir/", "sub/dir" },
    { "foo", "." },
    { "/foo", "/" },
    { "", "." },
    { "~/x/y", vim.env.HOME .. "/x" },
  }
  for _, case in ipairs(cases) do
    local got = M.dir_of_prompt(case[1])
    assert(got == case[2], string.format("prompt %q -> %q, want %q", case[1], got, case[2]))
  end
  print "dir_of_prompt ok"
end

-- test_dir_of_prompt()

return M
