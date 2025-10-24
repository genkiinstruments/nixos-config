-- ============================================================================
-- Undotree Configuration
-- ============================================================================
-- Visualize and navigate undo history as a tree
return {
    "mbbill/undotree",
    -- Lazy load when command is called
    cmd = "UndotreeToggle",
    -- Keybinding
    keys = {
        { "<Leader>gu", "<cmd>UndotreeToggle<CR>", desc = "Undo Tree" },
    },
}
