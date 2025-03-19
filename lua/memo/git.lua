-- Git integration functions for memo.nvim

local config = require('memo.config')

local M = {}

-- Stage changed files
function M.git_stage()
  local cfg = config.get()
  local memo_dir = vim.fn.expand(cfg.memo_dir)
  local current_dir = vim.fn.getcwd()

  -- Change to memo directory
  vim.cmd("cd " .. memo_dir)

  -- Run git add for only changed files
  local result = vim.fn.system("git add -u")

  -- Go back to original directory
  vim.cmd("cd " .. current_dir)

  if vim.v.shell_error ~= 0 then
    vim.notify("Git stage failed: " .. result, vim.log.levels.ERROR)
  else
    vim.notify("Changed files staged", vim.log.levels.INFO)
  end
end

-- Stage all files
function M.git_stage_all()
  local cfg = config.get()
  local memo_dir = vim.fn.expand(cfg.memo_dir)
  local current_dir = vim.fn.getcwd()

  -- Change to memo directory
  vim.cmd("cd " .. memo_dir)

  -- Run git add
  local result = vim.fn.system("git add .")

  -- Go back to original directory
  vim.cmd("cd " .. current_dir)

  if vim.v.shell_error ~= 0 then
    vim.notify("Git stage all failed: " .. result, vim.log.levels.ERROR)
  else
    vim.notify("All files staged", vim.log.levels.INFO)
  end
end

-- Commit changes
function M.git_commit(message)
  -- First stage changed files
  M.git_stage()

  if message == nil or message == "" then
    message = "update memos"
  end

  local cfg = config.get()
  local memo_dir = vim.fn.expand(cfg.memo_dir)
  local current_dir = vim.fn.getcwd()

  -- Change to memo directory
  vim.cmd("cd " .. memo_dir)

  -- Run git commit
  local result = vim.fn.system("git commit -m '" .. message .. "'")

  -- Go back to original directory
  vim.cmd("cd " .. current_dir)

  if vim.v.shell_error ~= 0 then
    vim.notify("Git commit failed: " .. result, vim.log.levels.ERROR)
  else
    vim.notify("Changes committed: " .. message, vim.log.levels.INFO)
  end
end

-- Stage and commit all changes
function M.git_commit_all(message)
  M.git_stage_all()
  M.git_commit(message)
end

-- Push changes to remote
function M.git_sync_push()
  local cfg = config.get()
  local memo_dir = vim.fn.expand(cfg.memo_dir)
  local current_dir = vim.fn.getcwd()

  -- Change to memo directory
  vim.cmd("cd " .. memo_dir)

  -- Run git push
  local result = vim.fn.system("git push")

  -- Go back to original directory
  vim.cmd("cd " .. current_dir)

  if vim.v.shell_error ~= 0 then
    vim.notify("Git push failed: " .. result, vim.log.levels.ERROR)
  else
    vim.notify("Changes pushed to remote", vim.log.levels.INFO)
  end
end

-- Pull changes from remote
function M.git_sync_pull()
  local cfg = config.get()
  local memo_dir = vim.fn.expand(cfg.memo_dir)
  local current_dir = vim.fn.getcwd()

  -- Change to memo directory
  vim.cmd("cd " .. memo_dir)

  -- Run git pull
  local result = vim.fn.system("git pull")

  -- Go back to original directory
  vim.cmd("cd " .. current_dir)

  if vim.v.shell_error ~= 0 then
    vim.notify("Git pull failed: " .. result, vim.log.levels.ERROR)
  else
    vim.notify("Changes pulled from remote", vim.log.levels.INFO)
  end
end

-- Show git status with return to original directory
function M.git_show_status()
  local cfg = config.get()
  local memo_dir = vim.fn.expand(cfg.memo_dir)
  local current_dir = vim.fn.getcwd()

  -- Check if fugitive is available
  local has_fugitive = pcall(vim.cmd, "silent! command Git")

  if has_fugitive then
    -- Use fugitive if available
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
    -- Change to memo directory
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
