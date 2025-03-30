return {
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require("cmp")
      
      -- Modify completion behavior to be less aggressive
      opts.completion = vim.tbl_extend("force", opts.completion or {}, {
        autocomplete = false,  -- Disable automatic popup
        completeopt = "menu,menuone,noinsert,noselect",  -- Don't auto-select items
      })
      
      -- Modify mapping to only show completion when explicitly requested
      opts.mapping = vim.tbl_extend("force", opts.mapping or {}, {
        ["<C-Space>"] = cmp.mapping.complete(),  -- Manually trigger completion with Ctrl+Space
        ["<CR>"] = cmp.mapping.confirm({
          behavior = cmp.ConfirmBehavior.Insert,
          select = false,  -- Only confirm explicitly selected items
        }),
      })
      
      -- Adjust the sources priority if needed
      -- This keeps the sources but makes them only appear when manually triggered
      -- You can also remove or reorder sources if desired
      
      return opts
    end,
  },
} 