return {

    -- add svelte to treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, { "nix" })
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter",
        dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
        opts = {
            context_commentstring = {
                config = {
                    lua = "|| %s",
                    nix = "# #",
                },
            },
        },
    },

    -- correctly setup mason lsp / dap extensions
    {
        "williamboman/mason.nvim",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, { "nil" })
        end,
    },
}
