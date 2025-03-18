-- Configuration module for memo.nvim

local M = {}

-- Default configuration
M.values = {
  memo_dir = vim.fn.expand("~/my-notes"),
  git_autocommit = false,
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
