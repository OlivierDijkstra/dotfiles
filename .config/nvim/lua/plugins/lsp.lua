-- Modern LSP setup with automatic server management
-- Uses Mason + mason-lspconfig + nvim-lspconfig for seamless experience

return {
  -- Mason: Package manager for LSP servers, formatters, linters
  {
    "williamboman/mason.nvim",
    opts = {
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗"
        }
      }
    }
  },

  -- Bridge between Mason and lspconfig 
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      -- Automatically install these language servers
      ensure_installed = {
        "lua_ls",           -- Lua
        "ts_ls",            -- TypeScript/JavaScript
        "biome",            -- BiomeJS (JS/TS linting + formatting)
        "html",             -- HTML
        "cssls",            -- CSS
        "tailwindcss",      -- Tailwind CSS
        "jsonls",           -- JSON
        "yamlls",           -- YAML
        "marksman",         -- Markdown
        "bashls",           -- Bash
        "pyright",          -- Python
        "rust_analyzer",    -- Rust
        "gopls",            -- Go
      },
      -- Automatically setup installed servers
      automatic_installation = true,
    }
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = { 
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp" -- For enhanced completion capabilities
    },
    config = function()
      local lspconfig = require("lspconfig")
      
      -- Enhanced capabilities for completion
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
      
      -- Configure diagnostic display
      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = false,
        float = {
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      })
      
      -- Auto show diagnostics on cursor hold
      vim.api.nvim_create_autocmd("CursorHold", {
        callback = function()
          local opts = {
            focusable = false,
            close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
            border = "rounded",
            source = "always",
            prefix = " ",
            scope = "cursor",
          }
          vim.diagnostic.open_float(nil, opts)
        end
      })
      
      -- Global LSP settings
      vim.lsp.config('*', {
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          -- Enable completion triggered by <c-x><c-o>
          vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
          
          -- LSP keymaps (only when LSP is attached)
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
          end
          
          -- VSCode-like navigation
          map("n", "gd", vim.lsp.buf.definition, "Go to definition")
          map("n", "gr", vim.lsp.buf.references, "Go to references") 
          map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
          
          -- VSCode-like actions with intuitive keys
          map("n", "<F2>", vim.lsp.buf.rename, "Rename symbol")              -- F2 like VSCode
          map("n", "<leader>.", vim.lsp.buf.code_action, "Quick fix")          -- Ctrl+. equivalent
          map("n", "<leader>k", vim.lsp.buf.hover, "Show info")               -- K but with leader
          map("n", "<C-space>", vim.lsp.buf.signature_help, "Signature help") -- Ctrl+Space like VSCode
          
          -- Diagnostics
          map("n", "<leader>d", vim.diagnostic.open_float, "Show line diagnostics")
          
          -- Formatting (Alt+Shift+F equivalent)
          map("n", "<leader>ff", vim.lsp.buf.format, "Format document")
          map("v", "<leader>ff", vim.lsp.buf.format, "Format selection")
        end
      })

      -- Language-specific configurations
      vim.lsp.config('lua_ls', {
        settings = {
          Lua = {
            runtime = { version = 'LuaJIT' },
            workspace = { 
              checkThirdParty = false,
              library = vim.api.nvim_get_runtime_file("", true)
            },
            telemetry = { enable = false },
            diagnostics = { globals = { 'vim' } }
          }
        }
      })

      vim.lsp.config('ts_ls', {
        settings = {
          typescript = {
            preferences = {
              includePackageJsonAutoImports = "auto"
            }
          }
        }
      })

      -- Enable BiomeJS LSP (built-in since Neovim 0.10)
      vim.lsp.enable('biome')
    end
  }
}