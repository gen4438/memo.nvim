-- Utility functions for memo.nvim

local M = {}

-- Ensure directory exists
function M.ensure_dir_exists(dir)
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
  end
end

-- Get date parts (year, month, day, week)
function M.get_date_parts()
  local date = os.date("*t")
  local year = tostring(date.year)
  local month = string.format("%02d", date.month)
  local day = string.format("%02d", date.day)

  -- ISO week number
  local iso_week = os.date("%V")

  -- Get the week of month (1-5)
  local first_day = os.time { year = date.year, month = date.month, day = 1 }
  local first_day_info = os.date("*t", first_day)
  local week_of_month = math.ceil((date.day + (first_day_info.wday - 2) % 7) / 7)

  -- Get start date of current week (Monday)
  local wday = date.wday
  local monday_offset = wday == 1 and -6 or (2 - wday)
  local monday = os.time { year = date.year, month = date.month, day = date.day + monday_offset }
  local monday_date = os.date("*t", monday)
  local week_start_month = string.format("%02d", monday_date.month)
  local week_start_day = string.format("%02d", monday_date.day)

  -- Get end date of current week (Sunday)
  local sunday = os.time { year = date.year, month = date.month, day = date.day + monday_offset + 6 }
  local sunday_date = os.date("*t", sunday)
  local week_end_month = string.format("%02d", sunday_date.month)
  local week_end_day = string.format("%02d", sunday_date.day)

  -- Format dates
  local date_format = year .. "/" .. month .. "/" .. day
  local week_start_format = year .. "/" .. week_start_month .. "/" .. week_start_day
  local week_end_format = year .. "/" .. week_end_month .. "/" .. week_end_day
  local month_format = year .. "/" .. month

  return year, month, day, iso_week, week_of_month, date_format, week_start_format, week_end_format, month_format
end

-- Sanitize title for filename (replace spaces, remove special chars)
function M.sanitize_title(title)
  return title:gsub(" ", "_"):gsub("[^%w_-]", "")
end

-- Complete project names from work directory
function M.complete_project_names(arg_lead, cmd_line, cursor_pos)
  local config = require('memo.config').get()
  local work_dir = vim.fn.expand(config.memo_dir .. "/note/work")

  if vim.fn.isdirectory(work_dir) == 0 then
    return {}
  end

  local projects = {}
  local handle = io.popen("ls -1 " .. work_dir)
  if handle then
    for line in handle:lines() do
      if vim.fn.isdirectory(work_dir .. "/" .. line) == 1 and line:find("^" .. arg_lead) then
        table.insert(projects, line)
      end
    end
    handle:close()
  end

  return projects
end

-- Complete language names for code memos
function M.complete_languages(arg_lead, cmd_line, cursor_pos)
  local config = require('memo.config').get()
  local code_dir = vim.fn.expand(config.memo_dir .. "/code")

  if vim.fn.isdirectory(code_dir) == 0 then
    return {}
  end

  local languages = {}
  local handle = io.popen("ls -1 " .. code_dir)
  if handle then
    for line in handle:lines() do
      if vim.fn.isdirectory(code_dir .. "/" .. line) == 1 and line:find("^" .. arg_lead) then
        table.insert(languages, line)
      end
    end
    handle:close()
  end

  return languages
end

return M
