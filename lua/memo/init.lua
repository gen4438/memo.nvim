-- memo.nvim - A Neovim plugin for memo management
-- Author: gen4438
-- Version: 1.0.0

local M = {}

function M.setup(opts)
  -- Load configuration
  require('memo.config').setup(opts)

  -- Create default templates if configured
  local cfg = require('memo.config').get()
  if cfg.create_default_templates then
    require('memo.template').create_default_templates()
  end

  -- Register commands and keymaps
  require('memo.commands').setup()

  return M
end

return M
