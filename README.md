# rails-schema.nvim

A small Neovim plugin for inspecting the current database schema of a Rails
model.

## Requirements

- Neovim 0.9+
- A Rails application with `bin/rails`
- `db/schema.rb`

## Installation (lazy.nvim)

```lua
{
  "matt-yeldalo/rails-schema.nvim",
  ft = "ruby",
  config = function()
    require("rails-schema").setup({
      border = "rounded",
      width = 0.6,
      height = 0.6,
      environment = "development",
    })

    vim.keymap.set("n", "<leader>rs", "<cmd>RailsSchema<cr>", {
      desc = "Toggle Rails schema",
    })
  end,
}
```

## Usage

From a Ruby model under `app/models`, run `:RailsSchema` or use your configured
mapping. Press `q` or `<Esc>` to close the floating window.

## Configuration

| Option              | Default        | Description                                       |
| ------------------- | -------------- | ------------------------------------------------- |
| `border`            | `rounded`      | Floating window border                            |
| `width`             | `0.55`         | Window width as a fraction of the editor          |
| `height`            | `0.65`         | Window height as a fraction of the editor         |
| `title`             | `Rails Schema` | Floating window title                             |
| `title_pos`         | `center`       | Title position                                    |
| `show_indexes`      | `true`         | Display indexes                                   |
| `show_foreign_keys` | `true`         | Display foreign keys                              |
| `rails_command`     | `bin/rails`    | Rails executable, relative to project root        |
| `environment`       | `development`  | Rails environment used to resolve the model table |

## Current limitations

- Reads `db/schema.rb`; `structure.sql` is not supported yet.
- Resolves the model's table name through `bin/rails runner`, so the Rails app
  must boot successfully.
- The parser intentionally targets common Rails schema dump syntax; unusual
  formatting and adapter-specific constructs may need additional handling.
- No caching yet: each invocation starts a Rails runner process.
