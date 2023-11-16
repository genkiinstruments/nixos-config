return {

    -- add C to treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, { "sql" })
        end,
    },

    -- correctly setup lsp / dap extensions
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                sqlls = {},
            },
        },
    },
}
