-- Periodic memo functions for memo.nvim

local utils = require('memo.utils')
local config = require('memo.config')

local M = {}

-- Open or create daily memo
function M.open_daily_memo()
  local year, month, day, _, _, date_format = utils.get_date_parts()
  local cfg = config.get()

  -- Create directory path
  local year_dir = vim.fn.expand(cfg.memo_dir .. "/note/general/" .. year)
  local month_dir = vim.fn.expand(year_dir .. "/" .. month)
  utils.ensure_dir_exists(month_dir)

  -- Create filename
  local filename = year .. "-" .. month .. "-" .. day .. "_daily.md"
  local filepath = month_dir .. "/" .. filename

  -- Create file if it doesn't exist
  if vim.fn.filereadable(filepath) == 0 then
    local file = io.open(filepath, "w")
    if file then
      file:write("# Daily Memo: " .. date_format .. "\n\n## Tasks\n\n- [ ] \n\n## Notes\n\n")
      file:close()
    end
  end

  -- Open file in editor
  vim.cmd("edit " .. filepath)
end

-- Open or create weekly memo
function M.open_weekly_memo()
  local year, month, day, iso_week, _, _, week_start_format, week_end_format = utils.get_date_parts()
  local cfg = config.get()

  -- Create directory path
  local year_dir = vim.fn.expand(cfg.memo_dir .. "/note/general/" .. year)
  utils.ensure_dir_exists(year_dir)

  -- Create filename
  local filename = year .. "-w" .. iso_week .. "_weekly.md"
  local filepath = year_dir .. "/" .. filename

  -- Create file if it doesn't exist
  if vim.fn.filereadable(filepath) == 0 then
    local file = io.open(filepath, "w")
    if file then
      file:write("# Weekly Memo: " ..
      week_start_format .. " - " .. week_end_format .. "\n\n## Goals\n\n- [ ] \n\n## Summary\n\n")
      file:close()
    end
  end

  -- Open file in editor
  vim.cmd("edit " .. filepath)
end

-- Open or create monthly memo
function M.open_monthly_memo()
  local year, month, _, _, _, _, _, _, month_format = utils.get_date_parts()
  local cfg = config.get()

  -- Create directory path
  local year_dir = vim.fn.expand(cfg.memo_dir .. "/note/general/" .. year)
  local month_dir = vim.fn.expand(year_dir .. "/" .. month)
  utils.ensure_dir_exists(month_dir)

  -- Create filename
  local filename = year .. "-" .. month .. "_monthly.md"
  local filepath = month_dir .. "/" .. filename

  -- Create file if it doesn't exist
  if vim.fn.filereadable(filepath) == 0 then
    local file = io.open(filepath, "w")
    if file then
      file:write("# Monthly Memo: " ..
      month_format .. "\n\n## Monthly Goals\n\n- [ ] \n\n## Achievements\n\n## Reflection\n\n")
      file:close()
    end
  end

  -- Open file in editor
  vim.cmd("edit " .. filepath)
end

-- Open or create yearly memo
function M.open_yearly_memo()
  local year = utils.get_date_parts()
  local cfg = config.get()

  -- Create directory path
  local year_dir = vim.fn.expand(cfg.memo_dir .. "/note/general/" .. year)
  utils.ensure_dir_exists(year_dir)

  -- Create filename
  local filename = year .. "_yearly.md"
  local filepath = year_dir .. "/" .. filename

  -- Create file if it doesn't exist
  if vim.fn.filereadable(filepath) == 0 then
    local file = io.open(filepath, "w")
    if file then
      file:write("# Yearly Memo: " .. year .. "\n\n## Annual Goals\n\n- [ ] \n\n## Key Projects\n\n## Year Review\n\n")
      file:close()
    end
  end

  -- Open file in editor
  vim.cmd("edit " .. filepath)
end

return M
