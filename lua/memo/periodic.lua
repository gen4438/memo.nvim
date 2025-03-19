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

  -- Open a new buffer with the file path
  vim.cmd("edit " .. filepath)

  -- If the file doesn't exist yet, set up template in the buffer only
  if vim.fn.filereadable(filepath) == 0 then
    local lines = {
      "# Daily Memo: " .. date_format,
      "",
      "## Tasks",
      "",
      "- [ ] ",
      "",
      "## Notes",
      ""
    }
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    -- File will only be created when the user explicitly saves
  end
end

-- Open or create weekly memo
function M.open_weekly_memo()
  local year, month, day, iso_week, _, _, week_start_format, week_end_format = utils.get_date_parts()
  local cfg = config.get()

  -- Create directory path
  local year_dir = vim.fn.expand(cfg.memo_dir .. "/note/general/" .. year)
  local month_dir = vim.fn.expand(year_dir .. "/" .. month)
  utils.ensure_dir_exists(month_dir)

  -- Create filename
  local filename = year .. "-w" .. iso_week .. "_weekly.md"
  local filepath = month_dir .. "/" .. filename

  -- Open a new buffer with the file path
  vim.cmd("edit " .. filepath)

  -- If the file doesn't exist yet, set up template in the buffer only
  if vim.fn.filereadable(filepath) == 0 then
    local lines = {
      "# Weekly Memo: " .. week_start_format .. " - " .. week_end_format,
      "",
      "## Goals",
      "",
      "- [ ] ",
      "",
      "## Summary",
      ""
    }
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    -- File will only be created when the user explicitly saves
  end
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

  -- Open a new buffer with the file path
  vim.cmd("edit " .. filepath)

  -- If the file doesn't exist yet, set up template in the buffer only
  if vim.fn.filereadable(filepath) == 0 then
    local lines = {
      "# Monthly Memo: " .. month_format,
      "",
      "## Monthly Goals",
      "",
      "- [ ] ",
      "",
      "## Achievements",
      "",
      "## Reflection",
      ""
    }
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    -- File will only be created when the user explicitly saves
  end
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

  -- Open a new buffer with the file path
  vim.cmd("edit " .. filepath)

  -- If the file doesn't exist yet, set up template in the buffer only
  if vim.fn.filereadable(filepath) == 0 then
    local lines = {
      "# Yearly Memo: " .. year,
      "",
      "## Annual Goals",
      "",
      "- [ ] ",
      "",
      "## Key Projects",
      "",
      "## Year Review",
      ""
    }
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    -- File will only be created when the user explicitly saves
  end
end

return M
