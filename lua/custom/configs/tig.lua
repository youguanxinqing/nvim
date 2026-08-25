local M = {}

local function git_root()
  local dir = vim.fn.expand "%:p:h"
  if dir == "" then
    dir = vim.fn.getcwd()
  end
  local out = vim.fn.systemlist { "git", "-C", dir, "rev-parse", "--show-toplevel" }
  if vim.v.shell_error ~= 0 or not out[1] or out[1] == "" then
    return nil
  end
  return out[1]
end

local function run(args, cwd)
  -- ponytail: deferred so `input()`'s trailing command-line state settles before
  -- termopen attaches its pty — first-run flash-close without this.
  vim.schedule(function()
    -- ponytail: right vertical split; swap to `botright new` for horizontal.
    vim.cmd "botright vnew"
    local win = vim.api.nvim_get_current_win()
    local cmd = { "tig" }
    vim.list_extend(cmd, args)
    vim.fn.termopen(cmd, {
      cwd = cwd,
      on_exit = function()
        vim.schedule(function()
          pcall(vim.api.nvim_win_close, win, true)
        end)
      end,
    })
    vim.cmd "startinsert"
  end)
end

local function file_rel()
  local abs = vim.fn.expand "%:p"
  if abs == "" then
    return nil
  end
  local root = git_root()
  if not root then
    return nil
  end
  local rel = abs
  if abs:sub(1, #root + 1) == root .. "/" then
    rel = abs:sub(#root + 2)
  end
  return root, rel
end

function M.blame()
  local root, rel = file_rel()
  if not root then
    vim.notify("tig: no file or not in a git repo", vim.log.levels.WARN)
    return
  end
  run({ "blame", "+" .. vim.fn.line ".", "--", rel }, root)
end

function M.log_file()
  local root, rel = file_rel()
  if not root then
    vim.notify("tig: no file or not in a git repo", vim.log.levels.WARN)
    return
  end
  -- Any non-zero count before the keymap flips --follow on (trace across renames).
  -- e.g. `<leader>gL` = normal; `1<leader>gL` = with --follow.
  local args = {}
  if vim.v.count > 0 then
    table.insert(args, "--follow")
  end
  table.insert(args, "--")
  table.insert(args, rel)
  run(args, root)
end

function M.status()
  local root = git_root()
  if not root then
    vim.notify("tig: not in a git repo", vim.log.levels.WARN)
    return
  end
  run({ "status" }, root)
end

-- Pickaxe: list commits that add/remove <pattern>. Uses selection in visual mode,
-- prompts otherwise. Scoped to current file when called from a real file buffer.
function M.pickaxe(pattern)
  local root = git_root()
  if not root then
    vim.notify("tig: not in a git repo", vim.log.levels.WARN)
    return
  end
  if not pattern or pattern == "" then
    pattern = vim.fn.input "tig -S: "
    if pattern == "" then
      return
    end
  end
  local args = { "-S" .. pattern }
  local abs = vim.fn.expand "%:p"
  if abs ~= "" and abs:sub(1, #root + 1) == root .. "/" then
    table.insert(args, "--")
    table.insert(args, abs:sub(#root + 2))
  end
  run(args, root)
end

-- Visual-selection variant: yank current selection (also exits visual mode)
-- and use it as the pickaxe pattern. Plain `y` (not `gvy`) — `'<`/`'>` marks
-- are stale on first invocation, so `gv` would re-select the wrong range.
function M.pickaxe_selection()
  local saved = vim.fn.getreg '"'
  local saved_type = vim.fn.getregtype '"'
  vim.cmd "silent noautocmd normal! y"
  local sel = vim.fn.getreg('"'):gsub("\n.*", "")
  vim.fn.setreg('"', saved, saved_type)
  if sel == "" then
    vim.notify("tig: empty selection", vim.log.levels.WARN)
    return
  end
  M.pickaxe(sel)
end

return M
