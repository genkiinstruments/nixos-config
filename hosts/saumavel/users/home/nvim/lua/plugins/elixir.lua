-- ============================================================================
-- Elixir LSP Configuration
-- ============================================================================
-- Custom LSP server configuration for Elixir development
return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            -- ================================================================
            -- Language Servers
            -- ================================================================
            servers = {
                -- Emmet Language Server for HTML/CSS expansion
                emmet_language_server = {
                    -- Supported file types
                    filetypes = {
                        "html",
                        "css",
                        "heex", -- Phoenix LiveView templates
                        -- "eex",     -- Embedded Elixir (disabled)
                        -- "elixir",  -- Elixir (disabled)
                        "javascript",
                        "javascriptreact",
                        "typescript",
                        "typescriptreact",
                    },
                },
            },
        },
    },
}
