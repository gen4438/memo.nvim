-- Memo creation functions for memo.nvim

local utils = require('memo.utils')
local config = require('memo.config')
local template = require('memo.template')

local M = {}

-- Create a general memo
function M.create_general_memo(title)
  local year, month, day = utils.get_date_parts()
  local sanitized_title = utils.sanitize_title(title)
  local cfg = config.get()

  local year_dir = vim.fn.expand(cfg.memo_dir .. "/general/notes/" .. year)
  local month_dir = vim.fn.expand(year_dir .. "/" .. month)

  local filename = year .. "-" .. month .. "-" .. day .. "_" .. sanitized_title .. ".md"
  local filepath = month_dir .. "/" .. filename

  -- Open a new buffer with the file path
  vim.cmd("edit " .. filepath)

  -- If the file doesn't exist yet, set up template in the buffer only
  if vim.fn.filereadable(filepath) == 0 then
    local content = template.get_processed_template("general", { title = title })
    if content then
      local lines = vim.split(content, "\n")
      vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    end
    -- File will only be created when the user explicitly saves
  end
end

-- Create a work memo for a specific project
function M.create_work_memo(project_name, title)
  local year, month, day = utils.get_date_parts()
  local sanitized_title = utils.sanitize_title(title)
  local cfg = config.get()

  local year_dir = vim.fn.expand(cfg.memo_dir .. "/work/" .. project_name .. "/" .. year)
  local month_dir = vim.fn.expand(year_dir .. "/" .. month)

  local filename = year .. "-" .. month .. "-" .. day .. "_" .. sanitized_title .. ".md"
  local filepath = month_dir .. "/" .. filename

  -- Open a new buffer with the file path
  vim.cmd("edit " .. filepath)

  -- If the file doesn't exist yet, set up template in the buffer only
  if vim.fn.filereadable(filepath) == 0 then
    local content = template.get_processed_template("work", {
      title = title,
      project = project_name
    })
    if content then
      local lines = vim.split(content, "\n")
      vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    end
    -- File will only be created when the user explicitly saves
  end
end

-- Create an experiment memo for a specific project
function M.create_experiment_memo(project_name, title)
  local year, month, day = utils.get_date_parts()
  local sanitized_title = utils.sanitize_title(title)
  local cfg = config.get()

  -- Get next experiment ID
  local exp_id = utils.get_next_experiment_id(project_name)

  -- Create directory structure: work/project/experiments/YYYY/MM/
  local year_dir = vim.fn.expand(cfg.memo_dir .. "/work/" .. project_name .. "/experiments/" .. year)
  local month_dir = vim.fn.expand(year_dir .. "/" .. month)

  -- Filename format: YYYY-MM-DD_expXXX_title.md
  local filename = year .. "-" .. month .. "-" .. day .. "_" .. exp_id .. "_" .. sanitized_title .. ".md"
  local filepath = month_dir .. "/" .. filename

  -- Open a new buffer with the file path
  vim.cmd("edit " .. filepath)

  -- If the file doesn't exist yet, set up template in the buffer only
  if vim.fn.filereadable(filepath) == 0 then
    local content = template.get_processed_template("experiment", {
      title = title,
      project = project_name,
      exp_id = exp_id
    })
    if content then
      local lines = vim.split(content, "\n")
      vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    end
    -- File will only be created when the user explicitly saves
  end
end

return M
