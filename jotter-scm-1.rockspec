rockspec_format = "3.0"
package = "jotter"
version = "scm-1"
source = {
   url = "git+https://github.com/username/jotter.nvim"
}
description = {
   summary = "Persistent markdown scratchpad in a centered floating window for Neovim",
   detailed = "jotter.nvim provides a distraction-free, persistent markdown scratchpad in a centered floating window with automatic saving and optional markdown rendering support.",
   homepage = "https://github.com/username/jotter.nvim",
   license = "MIT"
}
dependencies = {
   "lua >= 5.1"
}
build = {
   type = "builtin",
   modules = {
      ["jotter"] = "lua/jotter/init.lua",
      ["jotter.config"] = "lua/jotter/config.lua",
      ["jotter.state"] = "lua/jotter/state.lua",
      ["jotter.ui"] = "lua/jotter/ui.lua",
   }
}
