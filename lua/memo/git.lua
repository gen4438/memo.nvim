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

-- Show git status
function M.git_show_status()
  local cfg = config.get()
  local memo_dir = vim.fn.expand(cfg.memo_dir)
  local current_dir = vim.fn.getcwd()

  -- Change to memo directory
  vim.cmd("cd " .. memo_dir)

  -- Run git status and capture output
  local result = vim.fn.system("git status")

  -- Go back to original directory
  vim.cmd("cd " .. current_dir)

  -- Display result in a floating window
  if vim.v.shell_error ~= 0 then
    vim.notify("Git status failed: " .. result, vim.log.levels.ERROR)
  else
    -- Create a scratch buffer for the git status output
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(result, "\n"))

    -- Open in a floating window
    local width = math.min(80, vim.o.columns - 4)
    local height = math.min(20, vim.o.lines - 4)
    local win = vim.api.nvim_open_win(buf, true, {
      relative = "editor",
      width = width,
      height = height,
      row = math.floor((vim.o.lines - height) / 2),
      col = math.floor((vim.o.columns - width) / 2),
      style = "minimal",
      border = "rounded",
    })

    -- Set buffer options
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
    vim.api.nvim_win_set_option(win, "wrap", true)

    -- Add a keymap to close the window with 'q'
    vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
  end
end

return M
