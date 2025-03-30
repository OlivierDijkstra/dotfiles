return {
    {
        "lambdalisue/suda.vim",
        cmd = { "SudaRead", "SudaWrite" },
        keys = {
            { "<leader>W", "<cmd>SudaWrite<cr>", desc = "Write with sudo" },
        },
        config = function()
            vim.g.suda_smart_edit = 1
        end,
    },
}

