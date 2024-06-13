return {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
        {
            "-",
            "<cmd>Oil<cr>",
            { desc = "Open parent directory" },
        },
        {
            "<leader>e",
            "<cmd>Oil .<cr>",
            { desc = "Open nvim root directory" },
        },
        {
            "_",
            "<cmd>Oil .<cr>",
            { desc = "Open nvim root directory" },
        },
    },
    opts = {
        columns = {
            "icon",
            "permissions",
            "size",
            { "mtime", highlight = "Comment", format = "%T %y-%m-%d" },
        },
        float = {
            padding = 2,
            max_width = 155,
            max_height = 32,
            border = "rounded",
            win_options = {
                winblend = 0,
            },
            preview = {
                max_width = 0.9,
                min_width = { 40, 0.4 },
                width = nil,
                max_height = 0.9,
                min_height = { 5, 0.1 },
                height = nil,
                border = "rounded",
                win_options = {
                    winblend = 0,
                },
                update_on_cursor_moved = true,
            },
            override = function(conf)
                return conf
            end,
        },
        skip_confirm_for_simple_edits = true,
        view_options = {
            show_hidden = true,
        },
        delete_to_trash = true,
        prompt_save_on_select_new_entry = false,
        use_default_keymaps = false,
        experimental_watch_for_changes = true,
        default_file_explorer = true,
        keymaps = {
            ["<ESC>"] = "actions.close",
            ["q"] = "actions.close",
            ["?"] = "actions.show_help",
            ["<CR>"] = "actions.select",
            ["<C-v>"] = "actions.select_vsplit",
            ["<C-x>"] = "actions.select_split",
            ["K"] = "actions.preview",
            ["<C-r>"] = "actions.refresh",
            ["<BS>"] = "actions.parent",
            ["~"] = "actions.open_cwd",
            ["`"] = "actions.cd",
        },
    },
}
