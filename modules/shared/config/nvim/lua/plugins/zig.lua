return {
    -- correctly setup mason lsp / dap extensions
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                zls = {},
            },
        },
    },
}
