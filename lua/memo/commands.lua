-- Commands and keymaps for memo.nvim

local api = vim.api

local M = {}

-- Function to open or create todo.md
function M.open_todo()
  local memo = require('memo.memo')
  local utils = require('memo.utils')
  local cfg = require('memo.config').get()
  local template = require('memo.template')

  -- Create todo directory
  local todo_dir = vim.fn.expand(cfg.memo_dir .. "/todo")
  utils.ensure_dir_exists(todo_dir)

  -- Set the filepath
  local filepath = todo_dir .. "/todo.md"

  -- Open the file in a new buffer
  vim.cmd("edit " .. filepath)

  -- If the file doesn't exist yet, set up a template in the buffer
  if vim.fn.filereadable(filepath) == 0 then
    local content = template.get_processed_template("todo", {})
    local lines = vim.split(content, "\n")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    -- File will only be created when the user explicitly saves
  end
end

-- Interactive memo creation functions
function M.interactive_work_memo()
  local memo = require('memo.memo')
  local utils = require('memo.utils')

  -- Get list of available projects
  local projects = utils.complete_project_names("", "", 0)

  -- Add option for creating a new project
  table.insert(projects, 1, "+ Create new project")

  -- Show project selection
  vim.ui.select(projects, {
    prompt = "Select project or create new: ",
  }, function(selected)
    if not selected then
      return
    end

    if selected == "+ Create new project" then
      -- Prompt for new project name
      vim.ui.input({
        prompt = "Enter new project name: ",
      }, function(new_project)
        if new_project and new_project ~= "" then
          new_project = vim.trim(new_project)
          -- Now ask for a title
          vim.ui.input({
            prompt = "Enter memo title: ",
          }, function(title)
            if title and title ~= "" then
              title = vim.trim(title)
              memo.create_work_memo(new_project, title)
            end
          end)
        end
      end)
    else
      -- Selected an existing project
      vim.ui.input({
        prompt = "Enter memo title: ",
      }, function(title)
        if title and title ~= "" then
          title = vim.trim(title)
          memo.create_work_memo(selected, title)
        end
      end)
    end
  end)
end

function M.interactive_experiment_memo()
  local memo = require('memo.memo')
  local utils = require('memo.utils')

  -- Get list of available projects
  local projects = utils.complete_project_names("", "", 0)

  -- Add option for creating a new project
  table.insert(projects, 1, "+ Create new project")

  -- Show project selection
  vim.ui.select(projects, {
    prompt = "Select project for experiment: ",
  }, function(selected)
    if not selected then
      return
    end

    if selected == "+ Create new project" then
      -- Prompt for new project name
      vim.ui.input({
        prompt = "Enter new project name: ",
      }, function(new_project)
        if new_project and new_project ~= "" then
          new_project = vim.trim(new_project)
          -- Now ask for a title
          vim.ui.input({
            prompt = "Enter experiment title: ",
          }, function(title)
            if title and title ~= "" then
              title = vim.trim(title)
              memo.create_experiment_memo(new_project, title)
            end
          end)
        end
      end)
    else
      -- Selected an existing project
      vim.ui.input({
        prompt = "Enter experiment title: ",
      }, function(title)
        if title and title ~= "" then
          title = vim.trim(title)
          memo.create_experiment_memo(selected, title)
        end
      end)
    end
  end)
end


-- Setup commands and keymaps
function M.setup()
  -- Import modules locally rather than global variables

  -- Create commands for memo creation
  api.nvim_create_user_command("MemoNew", function(args)
    local title = vim.trim(args.args)
    require('memo.memo').create_general_memo(title)
  end, {
    nargs = 1,
    desc = "Create a new general memo",
  })

  api.nvim_create_user_command("MemoOpenTodo", function()
    M.open_todo()
  end, {
    desc = "Open todo list",
  })

  api.nvim_create_user_command("MemoNewWork", function(args)
    if args.args == "" then
      -- Interactive mode
      M.interactive_work_memo()
    else
      -- Traditional mode with arguments
      local trimmed_args = vim.trim(args.args)
      local parts = vim.split(trimmed_args, " ", { plain = true })
      if #parts < 2 then
        vim.notify("Usage: MemoNewWork project_name title", vim.log.levels.ERROR)
        return
      end
      local project_name = parts[1]
      local title = vim.trim(table.concat({ unpack(parts, 2) }, " "))
      require('memo.memo').create_work_memo(project_name, title)
    end
  end, {
    nargs = "?",
    desc = "Create a new work memo",
    complete = function(arg_lead, cmd_line, cursor_pos)
      local cmd_parts = vim.split(cmd_line, " ", { plain = true })
      if #cmd_parts == 2 then
        return require('memo.utils').complete_project_names(arg_lead, cmd_line, cursor_pos)
      end
      return {}
    end,
  })

  api.nvim_create_user_command("MemoNewExperiment", function(args)
    if args.args == "" then
      -- Interactive mode
      M.interactive_experiment_memo()
    else
      -- Traditional mode with arguments
      local trimmed_args = vim.trim(args.args)
      local parts = vim.split(trimmed_args, " ", { plain = true })
      if #parts < 2 then
        vim.notify("Usage: MemoNewExperiment project_name title", vim.log.levels.ERROR)
        return
      end
      local project_name = parts[1]
      local title = vim.trim(table.concat({ unpack(parts, 2) }, " "))
      require('memo.memo').create_experiment_memo(project_name, title)
    end
  end, {
    nargs = "?",
    desc = "Create a new experiment notebook",
    complete = function(arg_lead, cmd_line, cursor_pos)
      local cmd_parts = vim.split(cmd_line, " ", { plain = true })
      if #cmd_parts == 2 then
        return require('memo.utils').complete_project_names(arg_lead, cmd_line, cursor_pos)
      end
      return {}
    end,
  })


  -- Template management command
  api.nvim_create_user_command("MemoTemplateEdit", function(args)
    if args.args == "" then
      -- Show template type selection dialog
      local template = require('memo.template')
      local template_types = template.get_template_types()

      vim.ui.select(template_types, {
        prompt = "Select template to create or edit:",
      }, function(selected)
        if selected then
          template.edit_template(selected)
        end
      end)
    else
      require('memo.template').edit_template(args.args)
    end
  end, {
    nargs = "?",
    desc = "Create or edit a template",
    complete = function(arg_lead, cmd_line, cursor_pos)
      local template_types = require('memo.template').get_template_types()
      return vim.tbl_filter(function(item)
        return item:find(arg_lead) == 1
      end, template_types)
    end,
  })

  -- Periodic memo commands
  api.nvim_create_user_command("MemoOpenDaily", function()
    require('memo.periodic').open_daily_memo()
  end, {
    desc = "Open daily memo",
  })

  api.nvim_create_user_command("MemoOpenMonthly", function()
    require('memo.periodic').open_monthly_memo()
  end, {
    desc = "Open monthly memo",
  })

  -- FZF commands
  api.nvim_create_user_command("FzfMemoList", function()
    require('memo.search').fzf_memo_list()
  end, {
    desc = "List memos with fzf",
  })

  api.nvim_create_user_command("FzfMemoGrep", function()
    require('memo.search').fzf_memo_grep()
  end, {
    desc = "Grep memos with fzf",
  })

  api.nvim_create_user_command("FzfMemoTags", function()
    require('memo.search').fzf_memo_tags()
  end, {
    desc = "Search memo tags with fzf",
  })

  -- Git commands
  api.nvim_create_user_command("MemoGitStage", function()
    require('memo.git').git_stage()
  end, {
    desc = "Stage changed memo files",
  })

  api.nvim_create_user_command("MemoGitStageAll", function()
    require('memo.git').git_stage_all()
  end, {
    desc = "Stage all memo files",
  })

  api.nvim_create_user_command("MemoGitCommit", function(args)
    require('memo.git').git_commit(args.args)
  end, {
    nargs = "?",
    desc = "Commit memo changes",
  })

  api.nvim_create_user_command("MemoGitCommitAll", function(args)
    require('memo.git').git_commit_all(args.args)
  end, {
    nargs = "?",
    desc = "Stage and commit all memo changes",
  })

  api.nvim_create_user_command("MemoGitSyncPush", function()
    require('memo.git').git_sync_push()
  end, {
    desc = "Push memo changes to remote",
  })

  api.nvim_create_user_command("MemoGitSyncPull", function()
    require('memo.git').git_sync_pull()
  end, {
    desc = "Pull memo changes from remote",
  })

  api.nvim_create_user_command("MemoGitShowStatus", function()
    require('memo.git').git_show_status()
  end, {
    desc = "Show git status for memo repository",
  })

  -- AI integration command
  api.nvim_create_user_command("MemoSetupAI", function()
    require('memo.ai').setup_ai_templates()
  end, {
    desc = "Setup AI prompt templates for Claude Code and GitHub Copilot",
  })

  -- Set up keymaps
  local keymaps = {
    -- Memo creation
    { "n", "<leader>mnn",  ":MemoNew ",                  { desc = "Create new general memo", noremap = true } },
    { "n", "<leader>mt",   "<cmd>MemoOpenTodo<CR>",      { desc = "Open todo list", noremap = true } },
    { "n", "<leader>mnw",  ":MemoNewWork<CR>",           { desc = "Create new work memo (interactive)", noremap = true } },
    { "n", "<leader>mne",  ":MemoNewExperiment<CR>",     { desc = "Create new experiment notebook (interactive)", noremap = true } },

    -- Periodic memos
    { "n", "<leader>md",   "<cmd>MemoOpenDaily<CR>",     { desc = "Open daily memo", noremap = true } },
    { "n", "<leader>mm",   "<cmd>MemoOpenMonthly<CR>",   { desc = "Open monthly memo", noremap = true } },

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
