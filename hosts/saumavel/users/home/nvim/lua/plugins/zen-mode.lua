-- ============================================================================
-- Zen Mode Configuration
-- ============================================================================
-- Distraction-free coding with Twilight and Zen Mode
return {
    -- Twilight: Dim inactive portions of code
    "folke/twilight.nvim",
    -- Zen Mode: Focus on current buffer
    {
        "folke/zen-mode.nvim",
        cmd = "ZenMode",
        opts = {
            -- ================================================================
            -- Plugin Integrations
            -- ================================================================
            plugins = {
                -- Vim options to apply in zen mode
                options = {
                    enabled = true,
                    ruler = false, -- Disable ruler text in command line
                    showcmd = false, -- Disable command display in last line
                    laststatus = 0, -- Turn off statusline (0 = never shown)
                },
                -- Integration with other plugins
                gitsigns = true, -- Keep gitsigns enabled
                tmux = true, -- Resize tmux pane if inside tmux
            },
        },
        -- Keybinding
        keys = {
            { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen Mode" },
        },
    },
}
