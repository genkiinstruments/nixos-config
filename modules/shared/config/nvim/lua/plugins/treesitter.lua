return {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
        vim.list_extend(
            opts.ensure_installed,
            { "regex", "bash", "markdown", "markdown_inline", "elixir", "heex", "eex" }
        )
    end,
}
