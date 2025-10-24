-- ============================================================================
-- Treesitter Configuration
-- ============================================================================
-- Syntax highlighting and code understanding via tree-sitter
return {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
        -- ====================================================================
        -- Parser Configuration
        -- ====================================================================
        -- Ensure the 'ensure_installed' table exists
        opts.ensure_installed = opts.ensure_installed or {}
        -- Filter out incorrect/problematic parser names
        -- - 'c-sharp' is incorrect (should be 'c_sharp')
        -- - 'zig' is disabled due to errors
        opts.ensure_installed = vim.tbl_filter(function(parser)
            return parser ~= "c-sharp" and parser ~= "zig"
        end, opts.ensure_installed)
        -- Add the correct C# parser name
        vim.list_extend(opts.ensure_installed, { "c_sharp" })

        -- ====================================================================
        -- Highlighting Configuration
        -- ====================================================================
        -- Disable treesitter highlighting for Zig files to prevent errors
        opts.highlight = opts.highlight or {}
        opts.highlight.disable = opts.highlight.disable or {}
        table.insert(opts.highlight.disable, "zig")
    end,
}
