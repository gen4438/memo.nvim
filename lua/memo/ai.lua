-- AI integration for memo.nvim
-- Sets up prompt templates for Claude Code and GitHub Copilot

local config = require('memo.config')
local utils = require('memo.utils')

local M = {}

-- Get the path to the plugin's templates directory
local function get_plugin_template_dir()
  -- Get the path of this lua file
  local str = debug.getinfo(2, "S").source:sub(2)
  local plugin_dir = str:match("(.*/)")
  -- Go up from lua/memo/ to the plugin root
  return plugin_dir:gsub("lua/memo/$", "") .. "templates/prompts/"
end

-- Copy a file from source to destination
local function copy_file(src, dest)
  local src_file = io.open(src, "r")
  if not src_file then
    return false, "Failed to open source file: " .. src
  end

  local content = src_file:read("*all")
  src_file:close()

  local dest_file = io.open(dest, "w")
  if not dest_file then
    return false, "Failed to create destination file: " .. dest
  end

  dest_file:write(content)
  dest_file:close()

  return true
end

-- List of prompt template files to copy
local prompt_templates = {
  "expand-experiment.md",
  "improve-title.md",
  "organize-memo.md",
  "summarize-weekly.md",
  "compare-experiments.md",
}

-- AGENTS.md file (unified AI instructions format)
local agents_md_file = "AGENTS.md"

-- Setup AI templates in memo directory
function M.setup_ai_templates()
  local cfg = config.get()
  local memo_dir = vim.fn.expand(cfg.memo_dir)
  local template_src_dir = get_plugin_template_dir()

  -- Create .claude/commands directory
  local claude_dir = memo_dir .. "/.claude/commands"
  utils.ensure_dir_exists(claude_dir)

  -- Create .vscode/prompts directory
  local vscode_dir = memo_dir .. "/.vscode/prompts"
  utils.ensure_dir_exists(vscode_dir)

  -- Create .github directory
  local github_dir = memo_dir .. "/.github"
  utils.ensure_dir_exists(github_dir)

  local files_created = 0
  local files_skipped = 0
  local errors = {}

  -- Copy prompt templates for Claude Code
  for _, filename in ipairs(prompt_templates) do
    local src = template_src_dir .. filename
    local dest = claude_dir .. "/" .. filename

    if vim.fn.filereadable(dest) == 0 then
      local success, err = copy_file(src, dest)
      if success then
        files_created = files_created + 1
      else
        table.insert(errors, err)
      end
    else
      files_skipped = files_skipped + 1
    end
  end

  -- Copy prompt templates for VSCode Copilot (same files)
  for _, filename in ipairs(prompt_templates) do
    local src = template_src_dir .. filename
    local dest = vscode_dir .. "/" .. filename

    if vim.fn.filereadable(dest) == 0 then
      local success, err = copy_file(src, dest)
      if success then
        files_created = files_created + 1
      else
        table.insert(errors, err)
      end
    else
      files_skipped = files_skipped + 1
    end
  end

  -- Copy AGENTS.md to GitHub Copilot instructions location
  local agents_src = template_src_dir .. agents_md_file
  local copilot_dest = github_dir .. "/copilot-instructions.md"

  if vim.fn.filereadable(copilot_dest) == 0 then
    local success, err = copy_file(agents_src, copilot_dest)
    if success then
      files_created = files_created + 1
    else
      table.insert(errors, err)
    end
  else
    files_skipped = files_skipped + 1
  end

  -- Copy AGENTS.md to CLAUDE.md in memo root
  local claude_dest = memo_dir .. "/CLAUDE.md"

  if vim.fn.filereadable(claude_dest) == 0 then
    local success, err = copy_file(agents_src, claude_dest)
    if success then
      files_created = files_created + 1
    else
      table.insert(errors, err)
    end
  else
    files_skipped = files_skipped + 1
  end

  -- Show result message
  local message = string.format(
    "AI templates setup completed!\nCreated: %d files\nSkipped (already exists): %d files\n\nAGENTS.md copied to:\n- GitHub Copilot: %s\n- Claude Code: %s\n\nPrompt templates copied to:\n- Claude Code commands: %s\n- VSCode prompts: %s",
    files_created,
    files_skipped,
    copilot_dest,
    claude_dest,
    claude_dir,
    vscode_dir
  )

  if #errors > 0 then
    message = message .. "\n\nErrors:\n" .. table.concat(errors, "\n")
    vim.notify(message, vim.log.levels.WARN)
  else
    vim.notify(message, vim.log.levels.INFO)
  end
end

return M
