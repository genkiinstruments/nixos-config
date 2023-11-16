return {
    -- correctly setup mason lsp / dap extensions
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                nil_ls = {
                    settings = {
                        ["nil"] = {
                            formatting = {
                                command = { "nixpkgs-fmt" },
                            },
                        },
                    },
                },
            },
        },
    },
}
