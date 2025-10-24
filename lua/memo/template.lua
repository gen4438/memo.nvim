-- Template handling module for memo.nvim

local config = require('memo.config')
local utils = require('memo.utils')

local M = {}

-- Template placeholders:
-- {{title}} - The title of the memo
-- {{date}} - Current date in date_format
-- {{month}} - Current month in month_format
-- {{year}} - Current year in year_format
-- {{project}} - Project name (for work memos)
-- {{exp_id}} - Experiment ID (for experiment notebooks)

-- Get path to the plugin's default templates directory
function M.get_plugin_templates_dir()
  -- Use debug.getinfo to find the actual script path
  local source = debug.getinfo(1, "S").source
  if source:sub(1, 1) == "@" then
    source = source:sub(2)
  end
  local plugin_path = vim.fn.fnamemodify(source, ':p:h:h')
  return plugin_path .. "/templates"
end

-- Get a list of all available template types by scanning the plugin templates directory
function M.get_template_types()
  local template_types = {}
  local plugin_template_dir = M.get_plugin_templates_dir()

  -- Scan the plugin templates directory for .md files
  local handle = vim.loop.fs_scandir(plugin_template_dir)
  if handle then
    while true do
      local name, type = vim.loop.fs_scandir_next(handle)
      if not name then break end

      if type == "file" and name:match("%.md$") then
        -- Remove .md extension to get template type
        local template_type = name:gsub("%.md$", "")
        table.insert(template_types, template_type)
      end
    end
  end

  table.sort(template_types)
  return template_types
end

-- Create default templates in the template_dir by copying from plugin templates directory
function M.create_default_templates()
  local cfg = config.get()
  local template_dir = vim.fn.expand(cfg.template_dir)
  local plugin_template_dir = M.get_plugin_templates_dir()

  -- Ensure template directory exists
  utils.ensure_dir_exists(template_dir)

  -- Copy templates from plugin directory if they don't exist
  local template_types = M.get_template_types()
  for _, template_name in ipairs(template_types) do
    local template_path = template_dir .. "/" .. template_name .. ".md"
    local plugin_template_path = plugin_template_dir .. "/" .. template_name .. ".md"

    if vim.fn.filereadable(template_path) == 0 and vim.fn.filereadable(plugin_template_path) == 1 then
      -- Copy the file
      vim.fn.system("cp " .. vim.fn.shellescape(plugin_template_path) .. " " .. vim.fn.shellescape(template_path))
      vim.notify("Created default template: " .. template_name, vim.log.levels.INFO)
    end
  end
end

-- Create a specific template by copying from plugin templates directory
function M.create_template(template_type)
  local template_types = M.get_template_types()
  local is_valid = false
  for _, valid_type in ipairs(template_types) do
    if valid_type == template_type then
      is_valid = true
      break
    end
  end

  if not is_valid then
    vim.notify("Unknown template type: " .. template_type, vim.log.levels.ERROR)
    return false
  end

  local cfg = config.get()
  local template_dir = vim.fn.expand(cfg.template_dir)
  local plugin_template_dir = M.get_plugin_templates_dir()

  -- Ensure template directory exists
  utils.ensure_dir_exists(template_dir)

  local template_path = template_dir .. "/" .. template_type .. ".md"
  local plugin_template_path = plugin_template_dir .. "/" .. template_type .. ".md"

  -- Check if the template already exists
  if vim.fn.filereadable(template_path) == 1 then
    -- Confirm overwrite
    vim.ui.select({ "Yes", "No" }, {
      prompt = "Template '" .. template_type .. "' already exists. Overwrite?",
    }, function(choice)
      if choice == "Yes" then
        M.copy_template(plugin_template_path, template_path, template_type)
      end
    end)
  else
    -- Create new template
    return M.copy_template(plugin_template_path, template_path, template_type)
  end
end

-- Copy template from plugin directory to user directory
function M.copy_template(plugin_template_path, template_path, template_type)
  if vim.fn.filereadable(plugin_template_path) == 0 then
    vim.notify("Plugin template not found: " .. template_type, vim.log.levels.ERROR)
    return false
  end

  -- Copy the file
  vim.fn.system("cp " .. vim.fn.shellescape(plugin_template_path) .. " " .. vim.fn.shellescape(template_path))

  if vim.v.shell_error == 0 then
    vim.notify("Created template: " .. template_type, vim.log.levels.INFO)

    -- Open the template for editing
    vim.cmd("edit " .. vim.fn.fnameescape(template_path))
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

  -- Template not found
  vim.notify(
    "Template not found: " .. template_name .. "\n" ..
    "Please run :MemoInstallTemplates to install default templates.",
    vim.log.levels.ERROR
  )
  return nil
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

  -- Format dates according to configuration
  local date_str = os.date(cfg.date_format)
  local month_str = os.date(cfg.month_format)
  local year_str = os.date(cfg.year_format)

  -- Basic variables available to all templates
  local variables = {
    date = date_str,
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

  -- Return nil if template not found
  if not template_content then
    return nil
  end

  local variables = M.generate_variables(memo_info)
  return M.process_template(template_content, variables)
end

-- Edit a template
function M.edit_template(template_type)
  local template_types = M.get_template_types()
  local is_valid = false
  for _, valid_type in ipairs(template_types) do
    if valid_type == template_type then
      is_valid = true
      break
    end
  end

  if not is_valid then
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
      vim.fn.system("cp " .. vim.fn.shellescape(plugin_template_path) .. " " .. vim.fn.shellescape(template_path))
      vim.notify("Copied template from plugin: " .. template_type, vim.log.levels.INFO)
    else
      vim.notify("Template not found in plugin: " .. template_type, vim.log.levels.ERROR)
      return false
    end
  end

  -- Open the template file
  vim.cmd("edit " .. vim.fn.fnameescape(template_path))
  return true
end

return M
