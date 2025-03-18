-- FZF search functions for memo.nvim

local config = require('memo.config')

local M = {}

-- List all memos using fzf-lua
function M.fzf_memo_list()
  local has_fzf_lua, fzf_lua = pcall(require, "fzf-lua")
  if not has_fzf_lua then
    vim.notify("fzf-lua is not installed", vim.log.levels.ERROR)
    return
  end

  local cfg = config.get()

  fzf_lua.files({
    prompt = "Memos> ",
    cwd = cfg.memo_dir,
  })
end

-- Search memo contents using fzf-lua live_grep
function M.fzf_memo_grep()
  local has_fzf_lua, fzf_lua = pcall(require, "fzf-lua")
  if not has_fzf_lua then
    vim.notify("fzf-lua is not installed", vim.log.levels.ERROR)
    return
  end

  local cfg = config.get()

  fzf_lua.live_grep({
    prompt = "Grep Memos> ",
    cwd = cfg.memo_dir,
  })
end

-- Search for tags in memos using fzf-lua grep
function M.fzf_memo_tags()
  local has_fzf_lua, fzf_lua = pcall(require, "fzf-lua")
  if not has_fzf_lua then
    vim.notify("fzf-lua is not installed", vim.log.levels.ERROR)
    return
  end

  local cfg = config.get()

  -- Run rg to find #tags and pipe to fzf
  fzf_lua.grep({
    prompt = "Memo Tags> ",
    cwd = cfg.memo_dir,
    search = "#[\\w-]+",
  })
end

return M
