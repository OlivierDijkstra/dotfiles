-- Which-key: Shows available keybindings in a popup
-- Helps discover and remember commands when you press leader key

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    local wk = require("which-key")
    
    wk.setup({
      preset = "modern",
      delay = 300,
      win = {
        border = "rounded",
        padding = { 1, 2 },
      },
      icons = {
        breadcrumb = "»",
        separator = "➜",
        group = "+",
      },
      spec = {
        { "gr", hidden = true },  -- Hide gr from which-key to prevent conflicts
      },
    })

    -- Register group names for better organization
    wk.add({
      { "<leader>f", group = "Format/File" },
      { "<leader>c", group = "Code" },
      { "<leader>g", group = "Git" },
      { "<leader>u", group = "UI/Toggle" },
      { "<leader>x", group = "Diagnostics/Debug" },
      { "<leader>w", group = "Windows" },
      { "<leader>b", group = "Buffer" },
      { "<leader><tab>", group = "Tabs" },
      
      -- Document some key mappings
      { "<leader>.", desc = "Quick fix/Code actions" },
      { "<leader>k", desc = "Show hover info" },
      { "<leader>ff", desc = "Format document" },
      { "gd", desc = "Go to definition" },
      { "gi", desc = "Go to implementation" },
      { "F2", desc = "Rename symbol" },
      
      -- Navigation helpers
      { "H", desc = "Previous word" },
      { "L", desc = "Next word" },
      { "J", desc = "Jump 5 lines down" },
      { "K", desc = "Jump 5 lines up" },
    })
  end,
}