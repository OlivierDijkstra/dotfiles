-- Options are automatically loaded before lazy.nvim startup
-- Add any additional options here

local opt = vim.opt

-- Basic leader key
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Essential options only
opt.number = true -- Show line numbers
opt.mouse = "a" -- Enable mouse
opt.ignorecase = true -- Ignore case in search
opt.smartcase = true -- Override ignorecase if uppercase used
opt.termguicolors = true -- Enable 24-bit RGB colors
opt.clipboard = "unnamedplus" -- Use system clipboard
opt.updatetime = 250 -- Faster CursorHold trigger (default is 4000ms)

-- Indentation settings (matching VSCode defaults)
opt.tabstop = 2 -- Number of spaces tabs count for
opt.shiftwidth = 2 -- Size of an indent
opt.softtabstop = 2 -- Number of spaces tabs count for while editing
opt.expandtab = true -- Use spaces instead of tabs
opt.smartindent = true -- Insert indents automatically
opt.autoindent = true -- Copy indent from current line when starting new line
opt.shiftround = true -- Round indent to multiple of shiftwidth

-- Better formatting behavior
opt.wrap = false -- Disable line wrap
opt.breakindent = true -- Enable break indent
opt.linebreak = true -- Wrap lines at convenient points