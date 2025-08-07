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

    -- Auto open minimap
    vim.cmd("autocmd VimEnter * lua MiniMap.open()")
  end,
}