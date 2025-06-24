return {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Oil",
    keys = {
        -- {
        --     "<leader>w",
        --     "<cmd>Oil<cr>",
        --     { desc = "Open Oil" },
        -- },
        {
            "-",
            "<cmd>Oil<cr>",
            { desc = "Open parent directory" },
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
            -- "permissions",
            -- "size",
            -- { "mtime", highlight = "Comment", format = "%T %y-%m-%d" },
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
            ["?"] = "actions.show_help",
            ["K"] = "actions.preview",
            ["<ESC>"] = "actions.close",
            ["q"] = "actions.close",
            ["<CR>"] = "actions.select",
            ["l"] = "actions.select",
            ["<BS>"] = "actions.parent",
            ["h"] = "actions.parent",
            ["<C-v>"] = "actions.select_vsplit",
            ["<C-x>"] = "actions.select_split",
            ["<C-r>"] = "actions.refresh",
            ["~"] = "actions.open_cwd",
            ["`"] = "actions.cd",
        },
    },
}
