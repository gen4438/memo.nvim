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
  utils.ensure_dir_exists(month_dir)

  local filename = year .. "-" .. month .. "-" .. day .. "_" .. sanitized_title .. ".md"
  local filepath = month_dir .. "/" .. filename

  if vim.fn.filereadable(filepath) == 0 then
    local content = template.get_processed_template("general", { title = title })

    local file = io.open(filepath, "w")
    if file then
      file:write(content)
      file:close()
    end
  end

  vim.cmd("edit " .. filepath)
end

-- Create a work memo for a specific project
function M.create_work_memo(project_name, title)
  local year, month, day = utils.get_date_parts()
  local sanitized_title = utils.sanitize_title(title)
  local cfg = config.get()

  local year_dir = vim.fn.expand(cfg.memo_dir .. "/work/" .. project_name .. "/" .. year)
  local month_dir = vim.fn.expand(year_dir .. "/" .. month)
  utils.ensure_dir_exists(month_dir)

  local filename = year .. "-" .. month .. "-" .. day .. "_" .. sanitized_title .. ".md"
  local filepath = month_dir .. "/" .. filename

  if vim.fn.filereadable(filepath) == 0 then
    local content = template.get_processed_template("work", {
      title = title,
      project = project_name
    })

    local file = io.open(filepath, "w")
    if file then
      file:write(content)
      file:close()
    end
  end

  vim.cmd("edit " .. filepath)
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
  utils.ensure_dir_exists(month_dir)

  -- Filename format: YYYY-MM-DD_expXXX_title.md
  local filename = year .. "-" .. month .. "-" .. day .. "_" .. exp_id .. "_" .. sanitized_title .. ".md"
  local filepath = month_dir .. "/" .. filename

  if vim.fn.filereadable(filepath) == 0 then
    local content = template.get_processed_template("experiment", {
      title = title,
      project = project_name,
      exp_id = exp_id
    })

    local file = io.open(filepath, "w")
    if file then
      file:write(content)
      file:close()
    end
  end

  vim.cmd("edit " .. filepath)
end

return M
