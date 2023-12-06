return {

    -- add svelte to treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, { "svelte", "prisma", "sql", "typescript", "tsx" })
        end,
    },

    -- correctly setup mason lsp / dap extensions
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                svelte = {},
                prismals = {},
                tailwindcss = {},
                tsserver = {
                    keys = {
                        {
                            "<leader>co",
                            function()
                                vim.lsp.buf.code_action({
                                    apply = true,
                                    context = {
                                        only = { "source.organizeImports.ts" },
                                        diagnostics = {},
                                    },
                                })
                            end,
                            desc = "Organize Imports",
                        },
                        {
                            "<leader>cR",
                            function()
                                vim.lsp.buf.code_action({
                                    apply = true,
                                    context = {
                                        only = { "source.removeUnused.ts" },
                                        diagnostics = {},
                                    },
                                })
                            end,
                            desc = "Remove Unused Imports",
                        },
                    },
                    settings = {
                        typescript = {
                            format = {
                                indentSize = vim.o.shiftwidth,
                                convertTabsToSpaces = vim.o.expandtab,
                                tabSize = vim.o.tabstop,
                            },
                        },
                        javascript = {
                            format = {
                                indentSize = vim.o.shiftwidth,
                                convertTabsToSpaces = vim.o.expandtab,
                                tabSize = vim.o.tabstop,
                            },
                        },
                        completions = {
                            completeFunctionCalls = true,
                        },
                    },
                },
            },
        },
    },
}
