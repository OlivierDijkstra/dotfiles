return {
  "echasnovski/mini.map",
  version = false,
  config = function()
    local map = require("mini.map")
    map.setup({
      integrations = {
        map.gen_integration.diagnostic({
          error = "DiagnosticFloatingError",
          warn = "DiagnosticFloatingWarn",
          info = "DiagnosticFloatingInfo",
          hint = "DiagnosticFloatingHint",
        }),
      },
      symbols = {
        encode = map.gen_encode_symbols.dot("3x2"),
        scroll_line = "█",
        scroll_view = "┃",
      },
      window = {
        show_integration_count = false,
        width = 10,
        winblend = 0,
      },
    })

    -- Track minimap state
    local minimap_was_open = false
    
    -- Auto open minimap
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        vim.defer_fn(function()
          require("mini.map").open()
        end, 100)
      end,
    })

    -- Handle neo-tree toggle
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "neo-tree",
      callback = function()
        local minimap = require("mini.map")
        -- Check if minimap is currently open
        if minimap.current.win_data and minimap.current.win_data[1] then
          minimap_was_open = true
          minimap.close()
        end
      end,
    })

    -- Reopen minimap when leaving neo-tree
    vim.api.nvim_create_autocmd("WinClosed", {
      callback = function()
        vim.defer_fn(function()
          local neo_tree_open = false
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == "neo-tree" then
              neo_tree_open = true
              break
            end
          end
          if not neo_tree_open and minimap_was_open then
            require("mini.map").open()
            minimap_was_open = false
          end
        end, 50)
      end,
    })
  end,
}