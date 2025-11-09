-- Git integration functions for memo.nvim

local config = require('memo.config')

local M = {}

-- Check if fugitive.vim is available
local function has_fugitive()
  return pcall(vim.cmd, "silent! command Git")
end

-- Helper function to execute git commands with fugitive
-- Uses -C option to ensure commands run in memo directory
local function fugitive_exec(cmd, success_msg)
  local current_buf = vim.api.nvim_get_current_buf()
  local current_win = vim.api.nvim_get_current_win()
  local cfg = config.get()
  local memo_dir = vim.fn.expand(cfg.memo_dir)

  -- Record window count before execution
  local win_count_before = #vim.api.nvim_list_wins()

  -- Modify the Git command to use -C flag to specify the directory
  -- For example: "Git add -u" becomes "Git -C /path/to/memo add -u"
  local modified_cmd = cmd:gsub("^Git%s*", "Git -C " .. vim.fn.shellescape(memo_dir) .. " ")

  -- Execute the fugitive command with -C flag
  vim.cmd(modified_cmd)

  -- Return to original buffer/window for commands that don't show UI
  if not cmd:match("^Git$") then
    -- Close any windows that fugitive opened
    local win_count_after = #vim.api.nvim_list_wins()
    if win_count_after > win_count_before then
      -- Close the extra windows (usually fugitive status/result windows)
      for i = 1, win_count_after - win_count_before do
        -- Try to close the window that is not the original one
        local wins = vim.api.nvim_list_wins()
        for _, win in ipairs(wins) do
          if win ~= current_win and vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
            break
          end
        end
      end
    end

    vim.api.nvim_set_current_buf(current_buf)
    vim.api.nvim_set_current_win(current_win)

    -- Show success message if provided
    if success_msg then
      vim.notify(success_msg, vim.log.levels.INFO)
    end
  end
end

-- Helper function to execute git commands using shell
-- Uses git -C to execute in memo directory without changing cwd
local function shell_exec(git_cmd, success_msg, error_prefix)
  local cfg = config.get()
  local memo_dir = vim.fn.expand(cfg.memo_dir)

  -- Use git -C to execute in memo directory without changing cwd
  local full_cmd = string.format("git -C %s %s", vim.fn.shellescape(memo_dir), git_cmd)

  -- Run git command
  local result = vim.fn.system(full_cmd)

  if vim.v.shell_error ~= 0 then
    vim.notify(error_prefix .. ": " .. result, vim.log.levels.ERROR)
    return false
  else
    vim.notify(success_msg, vim.log.levels.INFO)
    return true
  end
end

-- Stage changed files
function M.git_stage()
  if has_fugitive() then
    fugitive_exec("Git add -u", "Changed files staged")
  else
    shell_exec("git add -u", "Changed files staged", "Git stage failed")
  end
end

-- Stage all files
function M.git_stage_all()
  if has_fugitive() then
    fugitive_exec("Git add .", "All files staged")
  else
    shell_exec("git add .", "All files staged", "Git stage all failed")
  end
end

-- Commit changes
function M.git_commit(message)
  -- First stage changed files
  M.git_stage()

  if message == nil or message == "" then
    message = "update memos"
  end

  if has_fugitive() then
    fugitive_exec(string.format("Git commit -m '%s'", message), "Changes committed: " .. message)
  else
    shell_exec("git commit -m '" .. message .. "'", "Changes committed: " .. message, "Git commit failed")
  end
end

-- Stage and commit all changes
function M.git_commit_all(message)
  M.git_stage_all()

  if message == nil or message == "" then
    message = "update all memos"
  end

  if has_fugitive() then
    fugitive_exec(string.format("Git commit -m '%s'", message), "All changes committed: " .. message)
  else
    shell_exec("git commit -m '" .. message .. "'", "All changes committed: " .. message, "Git commit failed")
  end
end

-- Push changes to remote
function M.git_sync_push()
  if has_fugitive() then
    fugitive_exec("Git push", "Changes pushed to remote")
  else
    shell_exec("git push", "Changes pushed to remote", "Git push failed")
  end
end

-- Pull changes from remote
function M.git_sync_pull()
  if has_fugitive() then
    fugitive_exec("Git pull", "Changes pulled from remote")
  else
    shell_exec("git pull", "Changes pulled from remote", "Git pull failed")
  end
end

-- Show git status
function M.git_show_status()
  local cfg = config.get()
  local memo_dir = vim.fn.expand(cfg.memo_dir)

  if has_fugitive() then
    -- Use fugitive for git status with -C flag
    fugitive_exec("Git", nil)
  else
    -- Fallback to shell command with git -C
    local result = vim.fn.system(string.format("git -C %s status", vim.fn.shellescape(memo_dir)))

    if vim.v.shell_error ~= 0 then
      vim.notify("Git status failed: " .. result, vim.log.levels.ERROR)
    else
      -- Create a scratch buffer for the git status output
      vim.cmd("new")
      local buf = vim.api.nvim_get_current_buf()
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(result, "\n"))

      -- Set buffer options
      vim.api.nvim_buf_set_option(buf, "modifiable", false)
      vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
      vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
      vim.api.nvim_buf_set_option(buf, "filetype", "git")

      -- Set buffer name
      vim.api.nvim_buf_set_name(buf, "git-status")

      -- Add a keymap to close the window with 'q'
      vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>bdelete<CR>", { noremap = true, silent = true })
    end
  end
end

return M
