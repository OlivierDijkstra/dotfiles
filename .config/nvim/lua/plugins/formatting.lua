-- Formatting and linting tools
-- Auto-formats code and provides additional linting beyond LSP

return {
  -- Formatter runner
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    opts = {
      -- Formatters by filetype
      formatters_by_ft = {
        lua = { "stylua" },
        -- Use BiomeJS for JS/TS (faster than Prettier)
        javascript = { "biome" },
        typescript = { "biome" },
        javascriptreact = { "biome" },
        typescriptreact = { "biome" },
        json = { "biome" },
        jsonc = { "biome" },
        -- Prettier for other web files
        css = { "prettier" },
        html = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        -- Language-specific formatters
        python = { "black" },
        rust = { "rustfmt" },
        go = { "gofmt" },
      },
      
      -- Format on save
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    },
  },

  -- Mason integration for formatters
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        -- Formatters
        "stylua",     -- Lua formatter
        "biome",      -- JS/TS/JSON formatter (faster than Prettier)
        "prettier",   -- CSS/HTML/YAML/MD formatter  
        "black",      -- Python formatter
        "rustfmt",    -- Rust formatter
        
        -- Additional linters
        "shellcheck", -- Bash/shell linting
      },
      auto_update = true,
      run_on_start = true,
    },
  },
}