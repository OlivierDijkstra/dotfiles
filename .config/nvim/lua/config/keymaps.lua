-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Make d and dd use the blackhole register so they don't affect the clipboard
vim.keymap.set({ "n", "v" }, "d", '"_d', { desc = "Delete without yanking", silent = true })
vim.keymap.set("n", "dd", '"_dd', { desc = "Delete line without yanking", silent = true })
vim.keymap.set("n", "D", '"_D', { desc = "Delete to end of line without yanking", silent = true })

-- Add a way to delete with the default behavior when needed
vim.keymap.set({ "n", "v" }, "<leader>d", "d", { desc = "Delete with default behavior", silent = true })
vim.keymap.set("n", "<leader>dd", "dd", { desc = "Delete line with default behavior", silent = true })
vim.keymap.set("n", "<leader>D", "D", { desc = "Delete to end of line with default behavior", silent = true })

vim.keymap.set("n", "<leader>/", "gcc", { desc = "Toggle comment", remap = true })
vim.keymap.set("v", "<leader>/", "gc", { desc = "Toggle comment selection", remap = true })

-- Shift+Arrow Up/Down to move 5 lines at a time
-- Normal mode
vim.keymap.set("n", "<S-Up>", "5k", { desc = "Move 5 lines up", silent = true })
vim.keymap.set("n", "<S-Down>", "5j", { desc = "Move 5 lines down", silent = true })

-- Visual mode
vim.keymap.set("v", "<S-Up>", "5k", { desc = "Move 5 lines up", silent = true })
vim.keymap.set("v", "<S-Down>", "5j", { desc = "Move 5 lines down", silent = true })

-- Alt+Arrow Up/Down to copy lines
-- Normal mode: Copy the entire current line up or down
vim.keymap.set("n", "<A-Down>", ":copy .<CR>", { desc = "Copy line down", silent = true })
vim.keymap.set("n", "<A-Up>", ":copy .-1<CR>", { desc = "Copy line up", silent = true })

-- Visual mode: Copy the selected text up or down
vim.keymap.set("v", "<A-Down>", ":copy '><CR>gv", { desc = "Copy selection down", silent = true })
vim.keymap.set("v", "<A-Up>", ":copy '<-1<CR>gv", { desc = "Copy selection up", silent = true })

-- Map q to quit in normal mode
vim.keymap.set("n", "q", ":q<CR>", { desc = "Quit", silent = true })

-- Map x to close current buffer in normal mode
vim.keymap.set("n", "x", ":bd<CR>", { desc = "Close current buffer", silent = true })

-- Buffer navigation (using BufferLine)
-- Ctrl+Tab to go to next buffer
vim.keymap.set("n", "<C-Tab>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer", silent = true })
-- Ctrl+Shift+Tab to go to previous buffer
vim.keymap.set("n", "<C-S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer", silent = true })

-- Alt+number to go to specific buffer
vim.keymap.set("n", "<A-1>", "<cmd>BufferLineGoToBuffer 1<CR>", { desc = "Go to buffer 1", silent = true })
vim.keymap.set("n", "<A-2>", "<cmd>BufferLineGoToBuffer 2<CR>", { desc = "Go to buffer 2", silent = true })
vim.keymap.set("n", "<A-3>", "<cmd>BufferLineGoToBuffer 3<CR>", { desc = "Go to buffer 3", silent = true })
vim.keymap.set("n", "<A-4>", "<cmd>BufferLineGoToBuffer 4<CR>", { desc = "Go to buffer 4", silent = true })
vim.keymap.set("n", "<A-5>", "<cmd>BufferLineGoToBuffer 5<CR>", { desc = "Go to buffer 5", silent = true })
vim.keymap.set("n", "<A-6>", "<cmd>BufferLineGoToBuffer 6<CR>", { desc = "Go to buffer 6", silent = true })
vim.keymap.set("n", "<A-7>", "<cmd>BufferLineGoToBuffer 7<CR>", { desc = "Go to buffer 7", silent = true })
vim.keymap.set("n", "<A-8>", "<cmd>BufferLineGoToBuffer 8<CR>", { desc = "Go to buffer 8", silent = true })
vim.keymap.set("n", "<A-9>", "<cmd>BufferLineGoToBuffer 9<CR>", { desc = "Go to buffer 9", silent = true })

-- Alternative buffer selection with leader+number (in case Alt+number doesn't work)
-- Buffer selection with leader+number or Ctrl+number
for i = 1, 9 do
  local cmd = "<cmd>BufferLineGoToBuffer " .. i .. "<CR>"
  local opts = { desc = "Go to buffer " .. i, silent = true }
  
  vim.keymap.set("n", "<leader>" .. i, cmd, opts)
  vim.keymap.set("n", "<C-" .. i .. ">", cmd, opts)
end

-- Ctrl+w to close buffer using BufferLinePickClose
vim.keymap.set("n", "<leader>w", "<cmd>BufferLinePickClose<CR>", { desc = "Pick buffer to close", silent = true })

-- Close all buffers except the current one
vim.keymap.set("n", "kw", "<cmd>BufferLineCloseOthers<CR>", { desc = "Close all buffers except current", silent = true })

-- Reordering buffers
vim.keymap.set("n", "<A-S-Left>", "<cmd>BufferLineMovePrev<CR>", { desc = "Move buffer left", silent = true })
vim.keymap.set("n", "<A-S-Right>", "<cmd>BufferLineMoveNext<CR>", { desc = "Move buffer right", silent = true })

-- NvimTree keybinds (similar to VSCode)
-- t toggles NvimTree, <leader>t focuses on NvimTree (opens if closed)
vim.keymap.set("n", "t", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer", silent = true })
vim.keymap.set("n", "<leader>t", "<cmd>NvimTreeFocus<CR>", { desc = "Focus file explorer", silent = true })

-- Navigation within NvimTree
-- Shift with arrows or j/k to move 5 items up or down
vim.api.nvim_create_autocmd("FileType", {
  pattern = "NvimTree",
  callback = function()
    local opts = { buffer = true, silent = true }
    vim.keymap.set("n", "<S-Down>", "5j", opts)
    vim.keymap.set("n", "<S-j>", "5j", opts)
    vim.keymap.set("n", "<S-Up>", "5k", opts)
    vim.keymap.set("n", "<S-k>", "5k", opts)
    
    -- Additional VSCode-like navigation
    vim.keymap.set("n", "<CR>", "o", opts) -- Open file/directory with Enter
    vim.keymap.set("n", "h", ":NvimTreeClose<CR>", opts) -- Close tree with h (like left arrow)
    vim.keymap.set("n", "l", "o", opts) -- Open with l (like right arrow)
    vim.keymap.set("n", "r", "a", opts) -- Rename with r
    vim.keymap.set("n", "a", "a", opts) -- Add file with a
    vim.keymap.set("n", "d", "d", opts) -- Delete with d
  end,
})
