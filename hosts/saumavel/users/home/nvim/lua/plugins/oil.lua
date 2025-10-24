-- ============================================================================
-- Oil.nvim Configuration
-- ============================================================================
-- File explorer that lets you edit your filesystem like a buffer
return {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- Lazy load when Oil command is called
    cmd = "Oil",

    -- ========================================================================
    -- Keybindings
    -- ========================================================================
    keys = {
        -- Open parent directory of current file
        {
            "-",
            "<cmd>Oil<cr>",
            { desc = "Open parent directory" },
        },
        -- Open nvim root directory (cwd)
        {
            "_",
            "<cmd>Oil .<cr>",
            { desc = "Open nvim root directory" },
        },
    },

    -- ========================================================================
    -- Configuration Options
    -- ========================================================================
    opts = {
        -- --------------------------------------------------------------------
        -- Display Columns
        -- --------------------------------------------------------------------
        columns = {
            "icon",
            -- "permissions",  -- Uncomment to show file permissions
            -- "size",         -- Uncomment to show file sizes
            -- { "mtime", highlight = "Comment", format = "%T %y-%m-%d" },  -- Modification time
        },

        -- --------------------------------------------------------------------
        -- Float Window Settings
        -- --------------------------------------------------------------------
        float = {
            padding = 2,
            max_width = 155,
            max_height = 32,
            border = "rounded",
            win_options = {
                winblend = 0,
            },
            -- Preview window configuration
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
            -- Custom window configuration override
            override = function(conf)
                return conf
            end,
        },

        -- --------------------------------------------------------------------
        -- Behavior Options
        -- --------------------------------------------------------------------
        skip_confirm_for_simple_edits = true,
        -- View options
        view_options = {
            show_hidden = true, -- Show hidden files (dotfiles)
        },
        delete_to_trash = true, -- Move deleted files to trash
        prompt_save_on_select_new_entry = false, -- Don't prompt to save when selecting new file
        use_default_keymaps = false, -- Disable default keymaps (using custom below)
        experimental_watch_for_changes = true, -- Auto-refresh when files change
        default_file_explorer = true, -- Use Oil as default file explorer

        -- --------------------------------------------------------------------
        -- Custom Keymaps
        -- --------------------------------------------------------------------
        keymaps = {
            ["?"] = "actions.show_help",
            ["K"] = "actions.preview",
            ["<ESC>"] = "actions.close",
            ["q"] = "actions.close",
            ["<CR>"] = "actions.select",
            ["l"] = "actions.select", -- Vim-style: 'l' to enter
            ["<BS>"] = "actions.parent",
            ["h"] = "actions.parent", -- Vim-style: 'h' to go up
            ["<C-v>"] = "actions.select_vsplit",
            ["<C-x>"] = "actions.select_split",
            ["<C-r>"] = "actions.refresh",
            ["~"] = "actions.open_cwd",
            ["`"] = "actions.cd",
        },
    },
}
