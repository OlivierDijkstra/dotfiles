-- Session management: Save and restore your workspace automatically

return {
  "folke/persistence.nvim",
  event = "BufReadPre",
  opts = {
    dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"), -- directory where session files are saved
    options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp" },
    pre_save = nil, -- function to run before saving
    save_empty = false, -- don't save if there are no open file buffers
  },
  keys = {
    -- Restore the session for the current directory
    {
      "<leader>qs",
      function()
        require("persistence").load()
      end,
      desc = "Restore Session",
    },
    -- Restore the last session
    {
      "<leader>ql",
      function()
        require("persistence").load({ last = true })
      end,
      desc = "Restore Last Session",
    },
    -- Stop persistence (don't save on exit)
    {
      "<leader>qd",
      function()
        require("persistence").stop()
      end,
      desc = "Don't Save Session",
    },
  },
  init = function()
    -- Automatically restore session when opening Neovim without arguments
    local function restore_session()
      -- Only restore if nvim was started with no arguments
      if vim.fn.argc(-1) == 0 then
        -- Check if a session exists for the current directory
        local persistence = require("persistence")
        if persistence then
          persistence.load()
        end
      end
    end

    -- Set up autocommand group for session management
    local group = vim.api.nvim_create_augroup("PerSessionManagement", { clear = true })
    
    -- Auto-restore session on startup
    vim.api.nvim_create_autocmd("VimEnter", {
      group = group,
      nested = true,
      callback = function()
        vim.schedule(restore_session)
      end,
    })

    -- Auto-save session on exit
    vim.api.nvim_create_autocmd("VimLeavePre", {
      group = group,
      callback = function()
        local persistence = require("persistence")
        if persistence then
          persistence.save()
        end
      end,
    })
  end,
}