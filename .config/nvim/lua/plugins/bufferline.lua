-- Buffer management with visual tabs like VSCode

return {
  -- Visual buffer tabs at the top
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    event = "VeryLazy",
    keys = {
      -- Navigate buffers like VSCode
      { "<Tab>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
      { "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous buffer" },
      
      -- Close buffers
      { "<leader>x", "<cmd>bdelete<cr>", desc = "Close current buffer" },
      { "<leader>X", "<cmd>BufferLineCloseOthers<cr>", desc = "Close other buffers" },
      
      -- Move buffers
      { "<A-,>", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer left" },
      { "<A-.>", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer right" },
      
      -- Pin/unpin buffer
      { "<leader>p", "<cmd>BufferLineTogglePin<cr>", desc = "Pin/Unpin buffer" },
      
      -- Pick buffer by letter
      { "<leader>bp", "<cmd>BufferLinePick<cr>", desc = "Pick buffer" },
      
      -- Go to specific buffer by number
      { "<leader>1", "<cmd>BufferLineGoToBuffer 1<cr>", desc = "Go to buffer 1" },
      { "<leader>2", "<cmd>BufferLineGoToBuffer 2<cr>", desc = "Go to buffer 2" },
      { "<leader>3", "<cmd>BufferLineGoToBuffer 3<cr>", desc = "Go to buffer 3" },
      { "<leader>4", "<cmd>BufferLineGoToBuffer 4<cr>", desc = "Go to buffer 4" },
      { "<leader>5", "<cmd>BufferLineGoToBuffer 5<cr>", desc = "Go to buffer 5" },
      { "<leader>6", "<cmd>BufferLineGoToBuffer 6<cr>", desc = "Go to buffer 6" },
      { "<leader>7", "<cmd>BufferLineGoToBuffer 7<cr>", desc = "Go to buffer 7" },
      { "<leader>8", "<cmd>BufferLineGoToBuffer 8<cr>", desc = "Go to buffer 8" },
      { "<leader>9", "<cmd>BufferLineGoToBuffer 9<cr>", desc = "Go to buffer 9" },
    },
    opts = {
      options = {
        mode = "buffers",
        numbers = "ordinal", -- Show buffer numbers
        close_command = "bdelete! %d",
        right_mouse_command = "bdelete! %d",
        left_mouse_command = "buffer %d",
        middle_mouse_command = nil,
        
        -- Visual styling
        indicator = {
          icon = "▎",
          style = "icon",
        },
        buffer_close_icon = "✕",
        modified_icon = "●",
        close_icon = "",
        left_trunc_marker = "",
        right_trunc_marker = "",
        
        -- Layout
        max_name_length = 18,
        max_prefix_length = 15,
        truncate_names = true,
        tab_size = 18,
        
        -- Diagnostics from LSP
        diagnostics = "nvim_lsp",
        diagnostics_update_in_insert = false,
        diagnostics_indicator = function(count, level, diagnostics_dict, context)
          local icon = level:match("error") and " " or " "
          return " " .. icon .. count
        end,
        
        -- Colors and styling
        color_icons = true,
        show_buffer_icons = true,
        show_buffer_close_icons = true,
        show_close_icon = true,
        show_tab_indicators = true,
        show_duplicate_prefix = true,
        persist_buffer_sort = true,
        
        -- Separator style (VSCode-like)
        separator_style = "thin",
        enforce_regular_tabs = false,
        always_show_bufferline = true,
        
        -- Sort by directory
        sort_by = "insert_after_current",
        
        -- Enable hover events
        hover = {
          enabled = true,
          delay = 200,
          reveal = { "close" },
        },
        
        -- Show pinned buffers separately
        offsets = {
          {
            filetype = "neo-tree",
            text = "File Explorer",
            text_align = "center",
            separator = true,
          },
        },
      },
      highlights = {
        buffer_selected = {
          bold = true,
          italic = false,
        },
        indicator_selected = {
          fg = { attribute = "fg", highlight = "Function" },
        },
      },
    },
  },

  -- Better buffer deletion (keeps window layout)
  {
    "famiu/bufdelete.nvim",
    keys = {
      { "<leader>bd", "<cmd>Bdelete<cr>", desc = "Delete buffer (keep window)" },
      { "<leader>bD", "<cmd>Bdelete!<cr>", desc = "Force delete buffer" },
    },
  },
}