-- Example plugin specification
-- Each plugin can be:
-- 1. A string: "owner/repo"
-- 2. A table with plugin spec: { "owner/repo", config = function() ... end }

return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { 
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-fzf-native.nvim",
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      
      telescope.setup({
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          path_display = { "truncate" },
          mappings = {
            i = {
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
              ["<ESC>"] = actions.close,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            file_ignore_patterns = { "%.git/", "node_modules/", "%.lock$" },
          },
          live_grep = {
            additional_args = function()
              return { "--hidden" }
            end,
          },
        },
      })
      
      -- Load FZF extension for better performance
      telescope.load_extension("fzf")
    end,
  },
  
  -- FZF native extension for better sorting performance
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
  },
}