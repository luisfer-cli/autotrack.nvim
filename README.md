# autotrack.nvim

Neovim plugin for automatic time tracking with timewarrior.

## Features

- Automatically detects when you switch files/buffers
- Starts/stops timewarrior tracking automatically
- Includes tags for:
  - Project name (current directory)
  - Current git branch
  - File type/programming language
- Customizable configuration

## Installation

### With lazy.nvim
```lua
{
  "luisfer-cli/autotrack.nvim",
  config = function()
    require("autotrack").setup()
  end
}
```

### With packer.nvim
```lua
use {
  "luisfer-cli/autotrack.nvim",
  config = function()
    require("autotrack").setup()
  end
}
```

## Configuration

```lua
require("autotrack").setup({
  enabled = true,                                    -- Enable autotracking by default
  task_name = "autotrack.nvim",                     -- Task name in timewarrior
  exclude_filetypes = { "help", "qf", "netrw", "fugitive", "git" }  -- File types to exclude
})
```

## Commands

- `:AutotrackStart` - Start autotracking
- `:AutotrackStop` - Stop autotracking
- `:AutotrackToggle` - Toggle autotracking
- `:AutotrackStatus` - Show current status

## Usage

The plugin starts automatically when loaded. Every time you switch buffers:

1. Stops current tracking (if any)
2. Starts new tracking with tags:
   - `autotrack.nvim` (task name)
   - `project:project_name` (directory name)
   - `branch:current_branch` (git branch or "no-git")
   - `lang:file_type` (language/file type)

## Timewarrior Report Examples

```bash
# View general plugin summary
timew summary autotrack.nvim

# View time by specific project
timew summary project:my-project

# View time by git branch
timew summary branch:main
timew summary branch:feature/new-feature

# View time by programming language
timew summary lang:lua
timew summary lang:python
timew summary lang:javascript

# Combine tags for more specific analysis
timew summary project:my-project lang:lua
timew summary project:my-project branch:main
timew summary autotrack.nvim project:my-project

# View detailed reports
timew report project:my-project
timew report lang:python :week

# View statistics by day/week/month
timew day project:my-project
timew week lang:lua
timew month autotrack.nvim

# Export data
timew export project:my-project
timew export autotrack.nvim :month
```

## Requirements

- Neovim 0.7+
- timewarrior installed and configured
- Git (optional, for branch detection)