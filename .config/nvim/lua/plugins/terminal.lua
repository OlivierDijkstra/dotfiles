return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = function(term)
          if term.direction == "horizontal" then
            return 15
          elseif term.direction == "vertical" then
            return vim.o.columns * 0.4
          end
        end,
        open_mapping = [[<c-j>]],
        hide_numbers = true,
        shade_terminals = false,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true,
        terminal_mappings = true,
        persist_size = true,
        persist_mode = true,
        direction = "horizontal",
        auto_scroll = true,
        close_on_exit = false,
        shell = vim.o.shell,
        float_opts = {
          border = "curved",
        },
      })

      function _G.set_terminal_keymaps()
        local opts = { buffer = 0 }
        vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
        vim.keymap.set("t", "<A-h>", [[<Cmd>wincmd h<CR>]], opts)
        vim.keymap.set("t", "<A-l>", [[<Cmd>wincmd l<CR>]], opts)
        vim.keymap.set("t", "<A-k>", [[<Cmd>wincmd k<CR>]], opts)
        vim.keymap.set("t", "<A-j>", [[<Cmd>wincmd j<CR>]], opts)
        vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], opts)
        vim.keymap.set("t", "<C-j>", [[<Cmd>ToggleTerm<CR>]], opts)
      end

      vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
      
      -- Force horizontal terminal
      vim.keymap.set("n", "<C-j>", function()
        vim.cmd("ToggleTerm direction=horizontal")
      end, { desc = "Toggle horizontal terminal" })
    end,
  },
}