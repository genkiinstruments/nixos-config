-- ============================================================================
-- Cloak.nvim Configuration
-- ============================================================================
-- Plugin for hiding sensitive information in files (e.g., environment variables)
return {
    "laytan/cloak.nvim",
    config = function()
        require("cloak").setup({
            -- ====================================================================
            -- General Settings
            -- ====================================================================
            enabled = true,
            cloak_character = "*",
            -- The applied highlight group (colors) on the cloaking
            highlight_group = "Comment",

            -- ====================================================================
            -- File Patterns
            -- ====================================================================
            patterns = {
                {
                    -- Match files starting with ".env" and other config files
                    file_pattern = {
                        ".env*",
                        "wrangler.toml",
                        ".dev.vars",
                    },
                    -- Match an equals sign and any character after it
                    -- This hides the values in KEY=VALUE pairs
                    cloak_pattern = "=.+",
                },
            },
        })
    end,
}
