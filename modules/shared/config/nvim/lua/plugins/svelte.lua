return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, { "svelte", "prisma", "sql", "typescript", "tsx" })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                svelte = {},
                prismals = {},
                tailwindcss = {},
            },
        },
    },
}
