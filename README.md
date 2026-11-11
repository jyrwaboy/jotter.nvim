# jotter.nvim

A persistent markdown scratchpad and clipboard history manager in a centered floating window or window split for Neovim.

## Features

- **Persistent**: Automatically saved on close and on exit (`VimLeavePre`).
- **Clipboard History Tab**: Automatically pulls your system clipboard into a separate `clipboard.md` tab whenever opened!
- **Flexible Display**: Open in a centered floating window or a window split (`below`, `above`, `left`, `right`).
- **Markdown Ready**: Integrates seamlessly with `render-markdown.nvim` when available.

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "jyrwaboy/jotter.nvim",
  config = function()
    require("jotter").setup({
      width = 0.75,
      height = 0.70,
      filename = "jotter.md",
      clip_filename = "jotter-clipboard.md",
      open_mode = "float",   -- "float" or "split"
      split_side = "below",  -- "below", "above", "left", "right"
      keymaps = {
        toggle = "<leader>j",
        split = "<leader>js",
        float = "<leader>jf",
        clip = "<leader>jc",  -- Optional: keymap to open clipboard history tab
      },
    })
  end
}
```

## Usage

- Press `<leader>j` (or `q` inside the jotter window) to toggle or close.
- Commands & Keymaps:
  - `:Jotter` (keymap: `<leader>j`) — Toggle main jotter scratchpad.
  - `:JotterClip` (keymap: `<leader>jc`) — Open clipboard history tab (auto-pulls latest clipboard copy).
  - `:JotterSplit` (keymap: `<leader>js`) — Open/switch to window split.
  - `:JotterFloat` (keymap: `<leader>jf`) — Open/switch to floating window.
  - `:JotterClose` — Close jotter.
