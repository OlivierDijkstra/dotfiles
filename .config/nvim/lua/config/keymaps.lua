-- Keymaps are automatically loaded on the VeryLazy event
-- Add any additional keymaps here

local map = vim.keymap.set

-- Better navigation with visual feedback
-- Keep cursor centered when jumping half pages
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Keep search results centered
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

-- Alternative quick movement (normal and visual modes)
map({ "n", "v" }, "J", "5j", { desc = "Jump 5 lines down" })
map({ "n", "v" }, "K", "5k", { desc = "Jump 5 lines up" })
map({ "n", "v" }, "H", "b", { desc = "Jump to previous word" })
map({ "n", "v" }, "L", "w", { desc = "Jump to next word" })

-- Command palette (custom plugin) - now using Ctrl+P
map("n", "<C-p>", function()
  require("command-palette").open()
end, { desc = "Command Palette" })

-- Window navigation (works everywhere including Neo-tree)
map("n", "<A-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<A-l>", "<C-w>l", { desc = "Go to right window" })
map("n", "<A-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<A-j>", "<C-w>j", { desc = "Go to lower window" })

-- Alternative: Use leader + hjkl for window navigation
map("n", "<leader>wh", "<C-w>h", { desc = "Window left" })
map("n", "<leader>wl", "<C-w>l", { desc = "Window right" })
map("n", "<leader>wk", "<C-w>k", { desc = "Window up" })
map("n", "<leader>wj", "<C-w>j", { desc = "Window down" })

-- Quick window cycling
map("n", "<A-Tab>", "<C-w>w", { desc = "Cycle through windows" })