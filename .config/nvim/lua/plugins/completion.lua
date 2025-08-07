-- Modern completion engine with LSP integration
-- Provides intelligent autocomplete for code, snippets, and more

return {
  -- Main completion engine
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      -- LSP completion source
      "hrsh7th/cmp-nvim-lsp",
      -- Buffer text completion
      "hrsh7th/cmp-buffer", 
      -- File path completion
      "hrsh7th/cmp-path",
      -- Command line completion
      "hrsh7th/cmp-cmdline",
      -- Snippet engine and completion
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      -- Pre-built snippets
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      
      -- Load friendly-snippets
      require("luasnip.loaders.from_vscode").lazy_load()
      
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        
        -- Completion menu appearance
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        
        -- Key mappings for completion
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          
          -- Tab to navigate and confirm
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        
        -- Completion sources (in priority order)
        sources = cmp.config.sources({
          { name = "nvim_lsp" },      -- LSP completions (highest priority)
          { name = "luasnip" },       -- Snippet completions
        }, {
          { name = "buffer" },        -- Buffer text completions
          { name = "path" },          -- File path completions
        }),
        
        -- Formatting for completion items
        formatting = {
          format = function(entry, vim_item)
            -- Source indicators
            local menu_icon = {
              nvim_lsp = "[LSP]",
              luasnip = "[Snip]",
              buffer = "[Buf]",
              path = "[Path]",
            }
            vim_item.menu = menu_icon[entry.source.name]
            return vim_item
          end,
        },
      })
      
      -- Command line completion
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" }
        }, {
          { name = "cmdline" }
        }),
      })
      
      -- Search completion
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" }
        },
      })
    end,
  },
}