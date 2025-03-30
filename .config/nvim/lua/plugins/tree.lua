return {
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        cmd = { "NvimTreeToggle", "NvimTreeFocus" },
        keys = {
            { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Explorer" },
            { "<leader>E", "<cmd>NvimTreeFocus<cr>", desc = "Explorer (Focus)" },
        },
        opts = {
            sort = {
                sorter = "case_sensitive",
            },
            view = {
                width = 30,
            },
            renderer = {
                group_empty = true,
            },
            filters = {
                dotfiles = false,
            },
            sync_root_with_cwd = true,
            respect_buf_cwd = true,
            update_focused_file = {
                enable = true,
                update_root = true,
            },
        },
        config = function(_, opts)
            require("nvim-tree").setup(opts)
            
            -- Auto close if nvim-tree is the last buffer
            vim.api.nvim_create_autocmd("BufEnter", {
                nested = true,
                callback = function()
                    if #vim.api.nvim_list_wins() == 1 and require("nvim-tree.utils").is_nvim_tree_buf() then
                        vim.cmd "quit"
                    end
                end
            })
        end,
    },
}
