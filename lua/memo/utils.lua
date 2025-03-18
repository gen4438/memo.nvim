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
  local week = os.date("%V") -- ISO week number

  return year, month, day, week
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
