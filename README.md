# jotter.nvim

A persistent markdown scratchpad in a centered floating window or window split for Neovim.

## Features

- **Persistent**: Automatically saved on close and on exit (`VimLeavePre`).
- **Flexible Display**: Open in a centered floating window or a window split (`below`, `above`, `left`, `right`). Seamlessly switch between float and split on the fly!
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
      open_mode = "float",   -- "float" or "split"
      split_side = "below",  -- "below", "above", "left", "right"
      keymaps = {
        toggle = "<leader>n",
        split = "<leader>ns",  -- Optional: keymap to open/switch to split
        float = "<leader>nf",  -- Optional: keymap to open/switch to float
      },
    })
  end
}
```

## Usage

- Press `<leader>n` (or `q` inside the jotter window) to toggle or close.
- Commands & Keymaps:
  - `:Jotter` (keymap: `<leader>n`) — Toggle jotter in configured mode (`float` or `split`).
  - `:JotterSplit` (keymap: `<leader>ns`) — Open or switch jotter to a window split.
  - `:JotterFloat` (keymap: `<leader>nf`) — Open or switch jotter to a floating window.
  - `:JotterClose` — Close jotter.
