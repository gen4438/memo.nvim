# memo.nvim

Neovim plugin for efficient memo management with fzf-lua integration and Git synchronization.

## Features

- Create different types of memos (general, work, experiment)
- Generate periodic memos (daily, weekly, monthly, yearly)
- Experiment notebook with auto-numbered IDs and structured templates
- Easy todo list management
- Search memos using fzf-lua
- Git integration for version control
- Customizable templates with placeholder variables
- Configurable date formats

## Requirements

- Neovim 0.7.0+ (required for `vim.keymap.set`)
- [fzf-lua](https://github.com/ibhagwan/fzf-lua) for search functionality
- Git (optional, for version control features)
- [fugitive.vim](https://github.com/tpope/vim-fugitive) (optional, for enhanced Git status)

## Installation

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'gen4438/memo.nvim',
  requires = { 'ibhagwan/fzf-lua' },
  config = function()
    require('memo').setup({
      -- Custom options (optional)
      memo_dir = vim.fn.expand("~/my-notes"),
      -- Template options
      template_dir = vim.fn.expand("~/my-notes/templates"),
      date_format = "%Y/%m/%d",
    })
  end
}
```

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'gen4438/memo.nvim',
  dependencies = { 'ibhagwan/fzf-lua' },
  opts = {
    -- Custom options (optional)
    memo_dir = vim.fn.expand("~/my-notes"),
    -- Template options
    template_dir = vim.fn.expand("~/my-notes/templates"),
    date_format = "%Y/%m/%d",
  },
}
```

## Directory Structure

The plugin creates and manages memos in the following structure:

```
my-notes/
├── templates/               # Template directory
│   ├── general.md           # Template for general memos
│   ├── work.md              # Template for work memos
│   ├── experiment.md        # Template for experiment notebooks
│   ├── daily.md             # Template for daily memos
│   ├── weekly.md            # Template for weekly memos
│   ├── monthly.md           # Template for monthly memos
│   └── yearly.md            # Template for yearly memos
├── todo/
│   └── todo.md              # Todo list
├── general/                 # General memos
│   ├── daily/               # Daily memos
│   │   └── YYYY/MM/YYYY-MM-DD_daily.md
│   ├── weekly/              # Weekly memos
│   │   └── YYYY/YYYY-wXX_weekly.md
│   ├── monthly/             # Monthly memos
│   │   └── YYYY/YYYY-MM_monthly.md
│   ├── yearly/              # Yearly memos
│   │   └── YYYY_yearly.md
│   └── notes/               # General notes
│       └── YYYY/MM/YYYY-MM-DD_title.md
└── work/                    # Work memos
    └── project1/
        ├── experiments/     # Experiment notebooks
        │   └── YYYY/MM/YYYY-MM-DD_expXXX_title.md
        └── YYYY/MM/YYYY-MM-DD_title.md
```

## Commands

### Memo Creation

- `:MemoNew <title>` - Create a new general memo
- `:MemoNewWork [project_name] [title]` - Create a work memo (interactive if no args)
- `:MemoNewExperiment [project_name] [title]` - Create an experiment notebook with auto-numbered ID (interactive if no args)

### Todo and Periodic Memos

- `:MemoOpenTodo` - Open/create the todo list
- `:MemoOpenDaily` - Open/create the daily memo
- `:MemoOpenWeekly` - Open/create the weekly memo
- `:MemoOpenMonthly` - Open/create the monthly memo
- `:MemoOpenYearly` - Open/create the yearly memo

Note: Periodic memos are created as buffers only and are saved to disk only when you explicitly save them.

### Search with fzf-lua

- `:FzfMemoList` - List all memos
- `:FzfMemoGrep` - Search memo contents
- `:FzfMemoTags` - Search for #tags in memos

### Git Integration

- `:MemoGitStage` - Stage changed files in the memo directory
- `:MemoGitStageAll` - Stage all files in the memo directory
- `:MemoGitCommit [message]` - Stage changed files and commit with an optional message (defaults to "update memos")
- `:MemoGitCommitAll [message]` - Stage and commit all changes
- `:MemoGitSyncPush` - Push commits to remote
- `:MemoGitSyncPull` - Pull changes from remote
- `:MemoGitShowStatus` - Show git status for memo repository (uses fugitive.vim if available)

### Template Management

- `:MemoTemplateEdit [type]` - Create or edit a template (interactive if no type specified)

## Keymaps

### Memo Creation

- `<leader>mnn` - Create new general memo
- `<leader>mnw` - Create new work memo (interactive)
- `<leader>mne` - Create new experiment notebook (interactive)

### Todo and Periodic Memos

- `<leader>mt` - Open todo list
- `<leader>md` - Open daily memo
- `<leader>mw` - Open weekly memo
- `<leader>mm` - Open monthly memo
- `<leader>my` - Open yearly memo

### Search with fzf-lua

- `<leader>ml` - List memos with fzf
- `<leader>mgg` - Grep memos with fzf
- `<leader>mgt` - Search memo tags with fzf

### Git Integration

- `<leader>mga` - Stage changed memo files
- `<leader>mgA` - Stage all memo files
- `<leader>mgc` - Stage and commit memo changes
- `<leader>mgC` - Stage and commit all memo changes
- `<leader>mgsh` - Push memo changes to remote
- `<leader>mgll` - Pull memo changes from remote
- `<leader>mgst` - Show git status for memo repository

## Configuration

You can customize the plugin by passing options to the setup function:

```lua
require('memo').setup({
  -- Main directory for memos
  memo_dir = vim.fn.expand("~/my-notes"),

  -- Template settings
  template_dir = vim.fn.expand("~/my-notes/templates"),
  create_default_templates = false,

  -- Date format settings (using Lua's os.date format)
  date_format = "%Y/%m/%d",
  week_format = "%Y/%m/%d - %Y/%m/%d",
  month_format = "%Y/%m",
  year_format = "%Y",
})
```

## Template System

The plugin includes a template system for customizing all memo types. Templates use placeholder variables that are automatically replaced with actual values when creating memos.

### Available Placeholders

- `{{title}}` - Title of the memo
- `{{date}}` - Current date (based on `date_format`)
- `{{week_start}}`, `{{week_end}}` - Start/end of current week
- `{{month}}` - Current month (based on `month_format`)
- `{{year}}` - Current year
- `{{project}}` - Project name (for work memos)
- `{{exp_id}}` - Experiment ID (for experiment notebooks, e.g., exp001)

Default templates are provided for all memo types. You can edit them using the `:MemoTemplateEdit` command.

## Experiment Notebooks

The plugin includes a specialized experiment notebook feature designed for data science, machine learning, and research workflows.

### Features

- **Auto-numbered IDs**: Experiment IDs are automatically assigned (exp001, exp002, ...) per project
- **Structured Template**: Comprehensive template covering all aspects of experiments:
  - Objective & Hypothesis
  - Environment & System Information
  - Input Data & Preprocessing
  - Method & Configuration (with YAML/JSON parameter blocks)
  - Execution Commands
  - Results (quantitative metrics, visualizations, outputs)
  - Analysis & Discussion
  - Conclusions & Next Steps
  - References & Related Work
- **Separate Directory**: Experiments are stored in `work/project/experiments/` to keep them organized separately from regular memos
- **Reproducibility**: Template includes fields for tracking Git commits, working directories, commands, and configuration files

### Usage

```vim
" Interactive mode (recommended)
:MemoNewExperiment
" or
<leader>mne

" Direct mode
:MemoNewExperiment my-project "hyperparameter tuning test"
```

The experiment notebook template is specifically designed for information systems and data analysis workflows, including sections for:
- Dataset information and preprocessing
- Model architecture and hyperparameters
- Performance metrics tables
- Error analysis
- Baseline comparisons

## Interactive Selection

When creating work memos or experiment notebooks without arguments, you can select existing projects or create new ones:

- Work memos: Choose from existing projects or select "+ Create new project"
- Experiment notebooks: Choose from existing projects or select "+ Create new project"

## Completion

- Work memo and experiment notebook project names are auto-completed based on existing directories
