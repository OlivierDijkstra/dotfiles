return {
  "AlexvZyl/nordic.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("nordic").setup({
      transparent_bg = false,
      bright_border = false,
      reduced_blue = true,
      swap_backgrounds = false,
      cursorline = {
        bold = false,
        bold_number = true,
        theme = "dark",
        blend = 0.85,
      },
      noice = {
        style = "classic",
      },
      telescope = {
        style = "classic",
      },
      leap = {
        dim_backdrop = false,
      },
      ts_context = {
        dark_background = true,
      },
    })
    vim.cmd("colorscheme nordic")
  end,
}