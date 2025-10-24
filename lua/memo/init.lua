-- memo.nvim - A Neovim plugin for memo management
-- Author: gen4438
-- Version: 1.0.0

local M = {}

function M.setup(opts)
  -- Load configuration
  require('memo.config').setup(opts)

  -- Add autocmd for automatic directory creation on save
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("MemoAutoCreateDir", { clear = true }),
    callback = function()
      local file = vim.fn.expand("<afile>")
      local dir = vim.fn.fnamemodify(file, ":p:h")

      -- Only create directories for normal files, not special protocols
      if vim.fn.isdirectory(dir) == 0 and vim.fn.match(file, [[^\w\+://]]) == -1 then
        vim.fn.mkdir(dir, "p")
      end
    end,
  })

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
