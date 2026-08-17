-- Load plugins / filetype plugins and indentation
vim.cmd("filetype plugin indent on")

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Tab completion
vim.opt.wildmode = { "list", "longest", "full" }
vim.opt.wildignore = {
  "*.swp",
  "*.o",
  "*.so",
  "*.exe",
  "*.dll",
}

-- Tab settings
vim.opt.tabstop = 2
vim.opt.expandtab = true

-- HUD
vim.opt.termguicolors = true
vim.cmd("syntax on")
vim.opt.cursorline = true
vim.opt.fillchars = { vert = "│" }
vim.opt.hidden = true
vim.opt.list = true
vim.opt.listchars = {
  tab = "»·",
  trail = "·",
}
vim.opt.foldenable = false
vim.opt.wrap = false
vim.opt.number = true
vim.opt.ruler = true
vim.opt.scrolloff = 3

-- Tags
vim.opt.tags = {
  "./tags;/",
  "tags;/",
}

-- Backup directories
vim.opt.backupdir = {
  "~/.config/nvim/backups",
  ".",
}

vim.opt.directory = {
  "~/.config/nvim/swaps",
  ".",
}

-- Undo directory
-- `undodir` exists in modern Neovim, so the exists() check is unnecessary.
vim.opt.undodir = {
  "~/.config/nvim/undo",
  ".",
}

-- Turn off search highlight
vim.keymap.set("n", "<localleader>/", "<cmd>nohlsearch<CR>")

require("vim._core.ui2").enable({})
