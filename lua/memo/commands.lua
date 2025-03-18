-- Commands and keymaps for memo.nvim

local memo = require('memo.memo')
local periodic = require('memo.periodic')
local search = require('memo.search')
local git = require('memo.git')
local utils = require('memo.utils')

local api = vim.api

local M = {}

-- Setup commands and keymaps
function M.setup()
  -- Create commands for memo creation
  api.nvim_create_user_command("MemoNew", function(args)
    memo.create_general_memo(args.args)
  end, {
    nargs = 1,
    desc = "Create a new general memo",
  })

  api.nvim_create_user_command("MemoNewWork", function(args)
    local parts = vim.split(args.args, " ", { plain = true })
    if #parts < 2 then
      vim.notify("Usage: MemoNewWork project_name title", vim.log.levels.ERROR)
      return
    end
    local project_name = parts[1]
    local title = table.concat({ unpack(parts, 2) }, " ")
    memo.create_work_memo(project_name, title)
  end, {
    nargs = "+",
    desc = "Create a new work memo",
    complete = function(arg_lead, cmd_line, cursor_pos)
      local cmd_parts = vim.split(cmd_line, " ", { plain = true })
      if #cmd_parts == 2 then
        return utils.complete_project_names(arg_lead, cmd_line, cursor_pos)
      end
      return {}
    end,
  })

  api.nvim_create_user_command("MemoNewPrompt", function(args)
    memo.create_prompt_memo(args.args)
  end, {
    nargs = 1,
    desc = "Create a new prompt memo",
  })

  api.nvim_create_user_command("MemoNewCode", function(args)
    local parts = vim.split(args.args, " ", { plain = true })
    if #parts < 2 then
      vim.notify("Usage: MemoNewCode language title", vim.log.levels.ERROR)
      return
    end
    local lang = parts[1]
    local title = table.concat({ unpack(parts, 2) }, " ")
    memo.create_code_memo(lang, title)
  end, {
    nargs = "+",
    desc = "Create a new code memo",
    complete = function(arg_lead, cmd_line, cursor_pos)
      local cmd_parts = vim.split(cmd_line, " ", { plain = true })
      if #cmd_parts == 2 then
        return utils.complete_languages(arg_lead, cmd_line, cursor_pos)
      end
      return {}
    end,
  })

  -- Periodic memo commands
  api.nvim_create_user_command("MemoOpenWeekly", function()
    periodic.open_weekly_memo()
  end, {
    desc = "Open weekly memo",
  })

  api.nvim_create_user_command("MemoOpenMonthly", function()
    periodic.open_monthly_memo()
  end, {
    desc = "Open monthly memo",
  })

  api.nvim_create_user_command("MemoOpenYearly", function()
    periodic.open_yearly_memo()
  end, {
    desc = "Open yearly memo",
  })

  -- FZF commands
  api.nvim_create_user_command("FzfMemoList", function()
    search.fzf_memo_list()
  end, {
    desc = "List memos with fzf",
  })

  api.nvim_create_user_command("FzfMemoGrep", function()
    search.fzf_memo_grep()
  end, {
    desc = "Grep memos with fzf",
  })

  api.nvim_create_user_command("FzfMemoTags", function()
    search.fzf_memo_tags()
  end, {
    desc = "Search memo tags with fzf",
  })

  -- Git commands
  api.nvim_create_user_command("MemoGitStage", function()
    git.git_stage()
  end, {
    desc = "Stage changed memo files",
  })

  api.nvim_create_user_command("MemoGitStageAll", function()
    git.git_stage_all()
  end, {
    desc = "Stage all memo files",
  })

  api.nvim_create_user_command("MemoGitCommit", function(args)
    git.git_commit(args.args)
  end, {
    nargs = "?",
    desc = "Commit memo changes",
  })

  api.nvim_create_user_command("MemoGitCommitAll", function(args)
    git.git_commit_all(args.args)
  end, {
    nargs = "?",
    desc = "Stage and commit all memo changes",
  })

  api.nvim_create_user_command("MemoGitSyncPush", function()
    git.git_sync_push()
  end, {
    desc = "Push memo changes to remote",
  })

  api.nvim_create_user_command("MemoGitSyncPull", function()
    git.git_sync_pull()
  end, {
    desc = "Pull memo changes from remote",
  })

  api.nvim_create_user_command("MemoGitShowStatus", function()
    git.git_show_status()
  end, {
    desc = "Show git status for memo repository",
  })

  -- Set up keymaps
  local keymaps = {
    -- Memo creation
    { "n", "<leader>mn",   "<cmd>MemoNew ",              { desc = "Create new general memo", noremap = true } },
    { "n", "<leader>mnw",  "<cmd>MemoNewWork ",          { desc = "Create new work memo", noremap = true } },
    { "n", "<leader>mnp",  "<cmd>MemoNewPrompt ",        { desc = "Create new prompt memo", noremap = true } },
    { "n", "<leader>mnc",  "<cmd>MemoNewCode ",          { desc = "Create new code memo", noremap = true } },

    -- Periodic memos
    { "n", "<leader>mw",   "<cmd>MemoOpenWeekly<CR>",    { desc = "Open weekly memo", noremap = true } },
    { "n", "<leader>mm",   "<cmd>MemoOpenMonthly<CR>",   { desc = "Open monthly memo", noremap = true } },
    { "n", "<leader>my",   "<cmd>MemoOpenYearly<CR>",    { desc = "Open yearly memo", noremap = true } },

    -- FZF integration
    { "n", "<leader>ml",   "<cmd>FzfMemoList<CR>",       { desc = "List memos with fzf", noremap = true } },
    { "n", "<leader>mgg",  "<cmd>FzfMemoGrep<CR>",       { desc = "Grep memos with fzf", noremap = true } },
    { "n", "<leader>mgt",  "<cmd>FzfMemoTags<CR>",       { desc = "Search memo tags with fzf", noremap = true } },

    -- Git integration
    { "n", "<leader>mga",  "<cmd>MemoGitStage<CR>",      { desc = "Stage changed memo files", noremap = true } },
    { "n", "<leader>mgA",  "<cmd>MemoGitStageAll<CR>",   { desc = "Stage all memo files", noremap = true } },
    { "n", "<leader>mgc",  "<cmd>MemoGitCommit<CR>",     { desc = "Commit memo changes", noremap = true } },
    { "n", "<leader>mgC",  "<cmd>MemoGitCommitAll<CR>",  { desc = "Stage and commit all memo changes", noremap = true } },
    { "n", "<leader>mgsh", "<cmd>MemoGitSyncPush<CR>",   { desc = "Push memo changes to remote", noremap = true } },
    { "n", "<leader>mgll", "<cmd>MemoGitSyncPull<CR>",   { desc = "Pull memo changes from remote", noremap = true } },
    { "n", "<leader>mgst", "<cmd>MemoGitShowStatus<CR>", { desc = "Show git status for memo repository", noremap = true } },
  }

  for _, mapping in ipairs(keymaps) do
    local mode, lhs, rhs, opts = unpack(mapping)
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

return M
