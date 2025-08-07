-- Auto-pairs and auto-tags for brackets and HTML elements

return {
  -- Auto-close brackets, quotes, parentheses
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local npairs = require("nvim-autopairs")
      npairs.setup({
        check_ts = true, -- Use treesitter for better pair matching
        disable_filetype = { "TelescopePrompt", "vim" },
        fast_wrap = {
          map = "<M-e>", -- Alt-e to fast wrap
          chars = { "{", "[", "(", '"', "'" },
          pattern = [=[[%'%"%>%]%)%}%,]]=],
          end_key = "$",
          keys = "qwertyuiopzxcvbnmasdfghjkl",
          check_comma = true,
          highlight = "Search",
          highlight_grey = "Comment"
        },
      })

      -- Integration with nvim-cmp if you have it
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp_status_ok, cmp = pcall(require, "cmp")
      if cmp_status_ok then
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
      end
    end,
  },

  -- Auto-close and rename HTML/XML tags
  {
    "windwp/nvim-ts-autotag",
    event = { "InsertEnter", "BufReadPost" },
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = function()
      require("nvim-ts-autotag").setup({
        opts = {
          enable_close = true, -- Auto close tags
          enable_rename = true, -- Auto rename pairs of tags
          enable_close_on_slash = true, -- Auto close on trailing </
        },
        filetypes = {
          "html", "javascript", "typescript", "javascriptreact", "typescriptreact",
          "vue", "tsx", "jsx", "xml", "php", "markdown", "astro", "glimmer",
          "handlebars", "hbs", "svelte"
        },
      })
    end,
  },
}