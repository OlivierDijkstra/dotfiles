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