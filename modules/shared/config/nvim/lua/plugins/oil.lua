return {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Oil",
    config = function()
        require("oil").setup()
    end,
    keys = {
        {
            "-",
            "<cmd>Oil --float<cr>",
            { desc = "Open parent directory" },
        },
        {
            "_",
            "<cmd>Oil --float .<cr>",
            { desc = "Open nvim root directory" },
        },
    },
    opts = {
        columns = {
            "icon",
            { "mtime", highlight = "Comment", format = "%T %y-%m-%d" },
        },
        skip_confirm_for_simple_edits = true,
        view_options = {
            show_hidden = true,
        },
        float = {
            padding = 3,
            win_options = {
                winblend = 0,
            },
        },
        prompt_save_on_select_new_entry = false,
        default_file_explorer = true,
        use_default_keymaps = false,
        keymaps = {
            ["<ESC>"] = "actions.close",
            ["q"] = "actions.close",
            ["?"] = "actions.show_help",
            ["<CR>"] = "actions.select",
            ["l"] = "actions.select",
            ["<C-v>"] = "actions.select_vsplit",
            ["<C-s>"] = "actions.select_split",
            ["K"] = "actions.preview",
            ["<esc>"] = "actions.close",
            ["r"] = "actions.refresh",
            ["<BS>"] = "actions.parent",
            ["h"] = "actions.parent",
            -- ["_"] = "actions.open_cwd",
            ["~"] = "actions.open_cwd",
            ["`"] = "actions.cd",
            ["cd"] = "actions.tcd",
            -- ["g."] = "actions.toggle_hidden",
            ["."] = "actions.toggle_hidden",
        },
    },
}
