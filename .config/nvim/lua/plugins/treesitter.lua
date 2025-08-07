-- TreeSitter: Advanced syntax highlighting and code understanding
-- Automatically installs parsers for better highlighting than regex-based syntax

return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects", -- Enhanced text objects
  },
  config = function()
    require("nvim-treesitter.configs").setup({
      -- Automatically install parsers for these languages
      ensure_installed = {
        "lua", "vim", "vimdoc", "query",
        "javascript", "typescript", "tsx", "json", "jsonc",
        "html", "css", "scss",
        "python", "rust", "go", "bash",
        "markdown", "markdown_inline", "yaml", "toml",
        "git_config", "gitcommit", "gitignore",
        "dockerfile", "sql"
      },
      
      -- Auto-install parsers for opened files
      auto_install = true,
      
      -- Enable syntax highlighting
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      
      -- Enable smart indentation
      indent = {
        enable = true,
      },
      
      -- Enhanced text objects (e.g., 'af' for a function, 'if' for inside function)
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["]f"] = "@function.outer",
            ["]c"] = "@class.outer",
          },
          goto_next_end = {
            ["]F"] = "@function.outer",
            ["]C"] = "@class.outer",
          },
          goto_previous_start = {
            ["[f"] = "@function.outer",
            ["[c"] = "@class.outer",
          },
          goto_previous_end = {
            ["[F"] = "@function.outer",
            ["[C"] = "@class.outer",
          },
        },
      },
    })
  end,
}