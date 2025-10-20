return {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
        -- Ensure the 'ensure_installed' table exists
        opts.ensure_installed = opts.ensure_installed or {}

        -- Filter out the incorrect 'c-sharp' parser name
        opts.ensure_installed = vim.tbl_filter(function(parser)
            return parser ~= "c-sharp"
        end, opts.ensure_installed)

        -- (Optional) If you actually want C# support, add the correct name.
        -- If you don't use C#, you can leave this line out.
        vim.list_extend(opts.ensure_installed, { "c_sharp" })
    end,
}
