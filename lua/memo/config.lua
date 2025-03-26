-- Configuration module for memo.nvim

local M = {}

-- Default configuration
M.values = {
  memo_dir = vim.fn.expand("~/my-notes"),
  git_autocommit = false,

  -- Template settings
  template_dir = vim.fn.expand("~/my-notes/templates"),

  -- Date format settings (using Lua's os.date format)
  date_format = "%Y/%m/%d",
  week_format = "%Y/%m/%d - %Y/%m/%d",
  month_format = "%Y/%m",
  year_format = "%Y",

  -- Whether to create default templates if they don't exist
  create_default_templates = true,
}

-- Setup function to merge user config with defaults
function M.setup(opts)
  if opts then
    M.values = vim.tbl_deep_extend("force", M.values, opts)
  end
end

-- Function to get current configuration
function M.get()
  return M.values
end

return M
