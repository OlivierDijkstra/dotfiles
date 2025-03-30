return {
    { 
        'datsfilipe/vesper.nvim',
        opts = {
            transparent = false,
            italics = {
                comments = true,
                keywords = true,
                functions = true,
                strings = true,
                variables = true,
            },
            overrides = {},
            palette_overrides = {},
        },
    },

    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "vesper",
        },
    },
}