return {
    -- add svelte to treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, { "regex", "bash", "markdown", "markdown_inline" })
        end,
    },
}
