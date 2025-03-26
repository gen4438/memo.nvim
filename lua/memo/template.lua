-- Template handling module for memo.nvim

local config = require('memo.config')
local utils = require('memo.utils')

local M = {}

-- Template placeholders:
-- {{title}} - The title of the memo
-- {{date}} - Current date in date_format
-- {{week_start}} - Start of week in date_format
-- {{week_end}} - End of week in date_format
-- {{month}} - Current month in month_format
-- {{year}} - Current year in year_format
-- {{project}} - Project name (for work memos)
-- {{language}} - Language name (for code memos)

-- Map of default templates for each memo type
local default_templates = {
  general = [[# {{title}}

Date: {{date}}

]],

  work = [[# {{title}}

Date: {{date}}
Project: {{project}}

]],

  prompt = [[# {{title}}

Date: {{date}}

]],

  code = [[# {{title}} ({{language}})

Date: {{date}}
Language: {{language}}

```{{language}}

```

]],

  daily = [[# Daily Memo: {{date}}

## Tasks

- [ ]

## Notes

]],

  weekly = [[# Weekly Memo: {{week_start}} - {{week_end}}

## Goals

- [ ]

## Summary

]],

  monthly = [[# Monthly Memo: {{month}}

## Monthly Goals

- [ ]

## Achievements

## Reflection

]],

  yearly = [[# Yearly Memo: {{year}}

## Annual Goals

- [ ]

## Key Projects

## Year Review

]],

  todo = [[# Todo List

## Today

- [ ]

## This Week

- [ ]

## Backlog

- [ ]
]]
}

-- Get path to the plugin's default templates directory
function M.get_plugin_templates_dir()
  -- Attempt to find the plugin's template directory
  local plugin_path = vim.fn.fnamemodify(vim.fn.expand('<sfile>'), ':p:h:h')
  return plugin_path .. "/templates"
end

-- Get a list of all available template types
function M.get_template_types()
  local template_types = {}
  for template_type, _ in pairs(default_templates) do
    table.insert(template_types, template_type)
  end
  table.sort(template_types)
  return template_types
end

-- Create default templates in the template_dir
function M.create_default_templates()
  local cfg = config.get()
  local template_dir = vim.fn.expand(cfg.template_dir)

  -- Ensure template directory exists
  utils.ensure_dir_exists(template_dir)

  -- Create default templates if they don't exist
  for template_name, content in pairs(default_templates) do
    local template_path = template_dir .. "/" .. template_name .. ".md"

    if vim.fn.filereadable(template_path) == 0 then
      local file = io.open(template_path, "w")
      if file then
        file:write(content)
        file:close()
        vim.notify("Created default template: " .. template_name, vim.log.levels.INFO)
      end
    end
  end
end

-- Create a specific template
function M.create_template(template_type)
  if not default_templates[template_type] then
    vim.notify("Unknown template type: " .. template_type, vim.log.levels.ERROR)
    return false
  end

  local cfg = config.get()
  local template_dir = vim.fn.expand(cfg.template_dir)

  -- Ensure template directory exists
  utils.ensure_dir_exists(template_dir)

  local template_path = template_dir .. "/" .. template_type .. ".md"

  -- Check if the template already exists
  if vim.fn.filereadable(template_path) == 1 then
    -- Confirm overwrite
    vim.ui.select({ "Yes", "No" }, {
      prompt = "Template '" .. template_type .. "' already exists. Overwrite?",
    }, function(choice)
      if choice == "Yes" then
        M.write_template(template_type, template_path)
      end
    end)
  else
    -- Create new template
    return M.write_template(template_type, template_path)
  end
end

-- Write template content to file
function M.write_template(template_type, template_path)
  local file = io.open(template_path, "w")
  if file then
    file:write(default_templates[template_type])
    file:close()
    vim.notify("Created template: " .. template_type, vim.log.levels.INFO)

    -- Open the template for editing
    vim.cmd("edit " .. template_path)
    return true
  else
    vim.notify("Failed to create template: " .. template_type, vim.log.levels.ERROR)
    return false
  end
end

-- Get the content of a template
function M.get_template(template_name)
  local cfg = config.get()
  local template_dir = vim.fn.expand(cfg.template_dir)
  local template_path = template_dir .. "/" .. template_name .. ".md"

  -- Check if user template file exists
  if vim.fn.filereadable(template_path) == 1 then
    local file = io.open(template_path, "r")
    if file then
      local content = file:read("*all")
      file:close()
      return content
    end
  end

  -- Check if plugin's template file exists
  local plugin_template_dir = M.get_plugin_templates_dir()
  local plugin_template_path = plugin_template_dir .. "/" .. template_name .. ".md"

  if vim.fn.filereadable(plugin_template_path) == 1 then
    local file = io.open(plugin_template_path, "r")
    if file then
      local content = file:read("*all")
      file:close()
      return content
    end
  end

  -- Fall back to default template
  return default_templates[template_name]
end

-- Process template with variables
function M.process_template(template_content, variables)
  local result = template_content

  -- Replace each placeholder with its value
  for placeholder, value in pairs(variables) do
    result = result:gsub("{{" .. placeholder .. "}}", value)
  end

  return result
end

-- Generate template variables based on current date and memo specific info
function M.generate_variables(memo_info)
  local cfg = config.get()
  local date = os.date("*t")

  -- Format dates according to configuration
  local date_str = os.date(cfg.date_format)
  local month_str = os.date(cfg.month_format)
  local year_str = os.date(cfg.year_format)

  -- Get week start and end dates
  local wday = date.wday
  local monday_offset = wday == 1 and -6 or (2 - wday)
  local monday = os.time { year = date.year, month = date.month, day = date.day + monday_offset }
  local sunday = os.time { year = date.year, month = date.month, day = date.day + monday_offset + 6 }

  local week_start = os.date(cfg.date_format, monday)
  local week_end = os.date(cfg.date_format, sunday)

  -- Basic variables available to all templates
  local variables = {
    date = date_str,
    week_start = week_start,
    week_end = week_end,
    month = month_str,
    year = year_str,
  }

  -- Add memo specific variables if provided
  if memo_info then
    for k, v in pairs(memo_info) do
      variables[k] = v
    end
  end

  return variables
end

-- Get processed template content for a given memo type and info
function M.get_processed_template(template_name, memo_info)
  local template_content = M.get_template(template_name)
  local variables = M.generate_variables(memo_info)

  return M.process_template(template_content, variables)
end

-- Edit a template
function M.edit_template(template_type)
  if not default_templates[template_type] then
    vim.notify("Unknown template type: " .. template_type, vim.log.levels.ERROR)
    return false
  end

  local cfg = config.get()
  local template_dir = vim.fn.expand(cfg.template_dir)
  local template_path = template_dir .. "/" .. template_type .. ".md"

  -- If the template doesn't exist in user directory, create it first
  if vim.fn.filereadable(template_path) == 0 then
    -- Copy from plugin template directory if it exists
    local plugin_template_dir = M.get_plugin_templates_dir()
    local plugin_template_path = plugin_template_dir .. "/" .. template_type .. ".md"

    if vim.fn.filereadable(plugin_template_path) == 1 then
      -- Ensure template directory exists
      utils.ensure_dir_exists(template_dir)

      -- Copy the file
      vim.fn.system("cp " .. plugin_template_path .. " " .. template_path)
      vim.notify("Copied template from plugin: " .. template_type, vim.log.levels.INFO)
    else
      -- Create a new template
      M.create_template(template_type)
      return true
    end
  end

  -- Open the template file
  vim.cmd("edit " .. template_path)
  return true
end

return M
