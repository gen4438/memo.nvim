-- memo.nvim - A Neovim plugin for memo management
-- Author: Claude
-- Version: 1.0.0

local M = {}

function M.setup(opts)
  -- Load configuration
  require('memo.config').setup(opts)

  -- Register commands and keymaps
  require('memo.commands').setup()

  return M
end

return M
