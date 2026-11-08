# jotter.nvim

A persistent markdown scratchpad in a centered floating window for Neovim.

## Features

- **Persistent**: Automatically saved on close and on exit (`VimLeavePre`).
- **Distraction-free**: Centered floating window with rounded borders and clean styling.
- **Markdown Ready**: Integrates seamlessly with `render-markdown.nvim` when available.
- **Modular**: Clean codebase structured for easy maintenance and extensibility.

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "username/jotter.nvim",
  config = function()
    require("jotter").setup({
      width = 0.75,
      height = 0.70,
      filename = "jotter.md",
      keymaps = {
        toggle = "<leader>n",
      },
    })
  end
}
```

## Usage

- Press `<leader>n` (or `q` inside the jotter window) to toggle or close.
- Run `:Jotter` or `:JotterClose`.
