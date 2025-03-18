-- Periodic memo functions for memo.nvim

local utils = require('memo.utils')
local config = require('memo.config')

local M = {}

-- Open or create a weekly memo
function M.open_weekly_memo()
  local year, _, _, week = utils.get_date_parts()
  local cfg = config.get()

  local year_dir = vim.fn.expand(cfg.memo_dir .. "/note/general/" .. year)
  utils.ensure_dir_exists(year_dir)

  local filename = year .. "-" .. week .. "_memo.md"
  local filepath = year_dir .. "/" .. filename

  if vim.fn.filereadable(filepath) == 0 then
    local file = io.open(filepath, "w")
    if file then
      file:write("# Weekly Memo: Week " .. week .. ", " .. year .. "\n\n")
      file:close()
    end
  end

  vim.cmd("edit " .. filepath)
end

-- Open or create a monthly memo
function M.open_monthly_memo()
  local year, month = utils.get_date_parts()
  local cfg = config.get()

  local year_dir = vim.fn.expand(cfg.memo_dir .. "/note/general/" .. year)
  local month_dir = vim.fn.expand(year_dir .. "/" .. month)
  utils.ensure_dir_exists(month_dir)

  local filename = year .. "-" .. month .. "_memo.md"
  local filepath = month_dir .. "/" .. filename

  if vim.fn.filereadable(filepath) == 0 then
    local file = io.open(filepath, "w")
    if file then
      file:write("# Monthly Memo: " .. month .. "/" .. year .. "\n\n")
      file:close()
    end
  end

  vim.cmd("edit " .. filepath)
end

-- Open or create a yearly memo
function M.open_yearly_memo()
  local year = utils.get_date_parts()
  local cfg = config.get()

  local year_dir = vim.fn.expand(cfg.memo_dir .. "/note/general/" .. year)
  utils.ensure_dir_exists(year_dir)

  local filename = year .. "_memo.md"
  local filepath = year_dir .. "/" .. filename

  if vim.fn.filereadable(filepath) == 0 then
    local file = io.open(filepath, "w")
    if file then
      file:write("# Yearly Memo: " .. year .. "\n\n")
      file:close()
    end
  end

  vim.cmd("edit " .. filepath)
end

return M
