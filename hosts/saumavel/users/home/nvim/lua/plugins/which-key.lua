-- ============================================================================
-- Which-Key Configuration
-- ============================================================================
-- Custom key group definitions for which-key popup
return {
    "folke/which-key.nvim",
    optional = true,
    opts = function(_, opts)
        -- ====================================================================
        -- Custom Key Groups
        -- ====================================================================
        -- Ensure the spec table exists
        if not opts.spec then
            opts.spec = {}
        end

        return opts
    end,
}
