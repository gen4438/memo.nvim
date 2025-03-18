-- Memo creation functions for memo.nvim

local utils = require('memo.utils')
local config = require('memo.config')

local M = {}

-- Create a general memo
function M.create_general_memo(title)
  local year, month, day = utils.get_date_parts()
  local sanitized_title = utils.sanitize_title(title)
  local cfg = config.get()

  local year_dir = vim.fn.expand(cfg.memo_dir .. "/note/general/" .. year)
  local month_dir = vim.fn.expand(year_dir .. "/" .. month)
  utils.ensure_dir_exists(month_dir)

  local filename = year .. "-" .. month .. "-" .. day .. "_" .. sanitized_title .. ".md"
  local filepath = month_dir .. "/" .. filename

  if vim.fn.filereadable(filepath) == 0 then
    local file = io.open(filepath, "w")
    if file then
      file:write("# " .. title .. "\n\n")
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

  local project_dir = vim.fn.expand(cfg.memo_dir .. "/note/work/" .. project_name)
  local year_dir = vim.fn.expand(project_dir .. "/" .. year)
  local month_dir = vim.fn.expand(year_dir .. "/" .. month)
  utils.ensure_dir_exists(month_dir)

  local filename = year .. "-" .. month .. "-" .. day .. "_" .. sanitized_title .. ".md"
  local filepath = month_dir .. "/" .. filename

  if vim.fn.filereadable(filepath) == 0 then
    local file = io.open(filepath, "w")
    if file then
      file:write("# " .. title .. "\n\n")
      file:close()
    end
  end

  vim.cmd("edit " .. filepath)
end

-- Create a prompt memo
function M.create_prompt_memo(title)
  local year, month, day = utils.get_date_parts()
  local sanitized_title = utils.sanitize_title(title)
  local cfg = config.get()

  local year_dir = vim.fn.expand(cfg.memo_dir .. "/note/prompt/" .. year)
  local month_dir = vim.fn.expand(year_dir .. "/" .. month)
  utils.ensure_dir_exists(month_dir)

  local filename = year .. "-" .. month .. "-" .. day .. "_" .. sanitized_title .. ".md"
  local filepath = month_dir .. "/" .. filename

  if vim.fn.filereadable(filepath) == 0 then
    local file = io.open(filepath, "w")
    if file then
      file:write("# " .. title .. "\n\n")
      file:close()
    end
  end

  vim.cmd("edit " .. filepath)
end

-- Create a code memo for a specific language
function M.create_code_memo(lang, title)
  local year, month, day = utils.get_date_parts()
  local sanitized_title = utils.sanitize_title(title)
  local cfg = config.get()

  local lang_dir = vim.fn.expand(cfg.memo_dir .. "/code/" .. lang)
  local year_dir = vim.fn.expand(lang_dir .. "/" .. year)
  local month_dir = vim.fn.expand(year_dir .. "/" .. month)
  utils.ensure_dir_exists(month_dir)

  local filename = year .. "-" .. month .. "-" .. day .. "_" .. sanitized_title .. ".md"
  local filepath = month_dir .. "/" .. filename

  if vim.fn.filereadable(filepath) == 0 then
    local file = io.open(filepath, "w")
    if file then
      file:write("# " .. title .. " (" .. lang .. ")\n\n```" .. lang .. "\n\n```\n")
      file:close()
    end
  end

  vim.cmd("edit " .. filepath)
end

return M
