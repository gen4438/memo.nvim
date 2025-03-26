-- Git integration functions for memo.nvim

local config = require('memo.config')

local M = {}

-- Check if fugitive.vim is available
local function has_fugitive()
  return pcall(vim.cmd, "silent! command Git")
end

-- Helper function to execute git commands with fugitive
local function fugitive_exec(cmd, success_msg)
  local current_buf = vim.api.nvim_get_current_buf()
  local current_win = vim.api.nvim_get_current_win()
  local cfg = config.get()
  local memo_dir = vim.fn.expand(cfg.memo_dir)

  -- Preserve current directory
  local current_dir = vim.fn.getcwd()
  vim.cmd("cd " .. memo_dir)

  -- Execute the fugitive command
  vim.cmd(cmd)

  -- Return to original directory
  vim.cmd("cd " .. current_dir)

  -- Return to original buffer/window for commands that don't show UI
  if not cmd:match("^Git$") then
    vim.api.nvim_set_current_buf(current_buf)
    vim.api.nvim_set_current_win(current_win)

    -- Show success message if provided
    if success_msg then
      vim.notify(success_msg, vim.log.levels.INFO)
    end
  end
end

-- Helper function to execute git commands using shell
local function shell_exec(git_cmd, success_msg, error_prefix)
  local cfg = config.get()
  local memo_dir = vim.fn.expand(cfg.memo_dir)
  local current_dir = vim.fn.getcwd()

  -- Change to memo directory
  vim.cmd("cd " .. memo_dir)

  -- Run git command
  local result = vim.fn.system(git_cmd)

  -- Go back to original directory
  vim.cmd("cd " .. current_dir)

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
  local current_dir = vim.fn.getcwd()

  if has_fugitive() then
    -- Use fugitive for git status
    -- Store current buffer to return to it later
    local current_buf = vim.api.nvim_get_current_buf()

    -- Execute Git command in memo directory
    vim.cmd("cd " .. memo_dir)
    vim.cmd("Git")

    -- Return to original directory after fugitive buffer is shown
    vim.defer_fn(function()
      vim.cmd("cd " .. current_dir)
    end, 100) -- Small delay to ensure Git command completes
  else
    -- Fallback to shell command
    vim.cmd("cd " .. memo_dir)

    -- Run git status and capture output
    local result = vim.fn.system("git status")

    -- Go back to original directory
    vim.cmd("cd " .. current_dir)

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
