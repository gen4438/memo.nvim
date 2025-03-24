# memo.nvim

Neovim plugin for efficient memo management with fzf-lua integration and Git synchronization.

## Features

- Create different types of memos (general, work, prompt, code)
- Generate periodic memos (daily, weekly, monthly, yearly)
- Easy todo list management
- Search memos using fzf-lua
- Git integration for version control

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
  },
}
```

## Directory Structure

The plugin creates and manages memos in the following structure:

```
my-notes/
├── todo/
│   └── todo.md           # Todo list
├── prompt/
├── note/
│   ├── work/
│   │   ├── project1/
│   │   │   ├── YYYY/MM/YYYY-MM-DD_note1.md
│   │   │   └── YYYY/MM/YYYY-MM-DD_note2.md
│   │   └── project2/
│   └── general/
│       ├── YYYY/MM/YYYY-MM-DD_daily.md     # Daily memo
│       ├── YYYY/MM/YYYY-MM-wXX_weekly.md   # Weekly memo (XX is week number)
│       ├── YYYY/MM/YYYY-MM_monthly.md      # Monthly memo
│       ├── YYYY/YYYY_yearly.md             # Yearly memo
│       ├── YYYY/MM/YYYY-MM-DD_note1.md
│       └── YYYY/MM/YYYY-MM-DD_note2.md
└── code/
    ├── python/
    │   ├── YYYY/MM/YYYY-MM-DD_script1.md
    │   ├── YYYY/MM/YYYY-MM-DD_script2.md
    ├── javascript/
    ├── golang/
    ├── other_language/
```

## Commands

### Memo Creation

- `:MemoNew <title>` - Create a new general memo
- `:MemoNewWork [project_name] [title]` - Create a work memo (interactive if no args)
- `:MemoNewPrompt <title>` - Create a new prompt memo
- `:MemoNewCode [lang] [title]` - Create a code memo (interactive if no args)

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

## Keymaps

### Memo Creation

- `<leader>mnn` - Create new general memo
- `<leader>mnw` - Create new work memo (interactive)
- `<leader>mnp` - Create new prompt memo
- `<leader>mnc` - Create new code memo (interactive)

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
  memo_dir = vim.fn.expand("~/custom-notes-path"),
  git_autocommit = false,
})
```

## Interactive Selection

When creating work memos or code memos, you can select existing projects/languages or create new ones:

- Work memos: Choose from existing projects or select "+ Create new project"
- Code memos: Choose from existing languages or select "+ Create new language"

## Completion

- Work memo project names are auto-completed based on existing directories
- Code memo languages are auto-completed based on existing directories
