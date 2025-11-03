-- ============================================================================
-- Lazy.nvim Configuration
-- ============================================================================
-- Plugin manager setup and configuration for LazyVim

-- ============================================================================
-- Bootstrap Lazy.nvim
-- ============================================================================

-- Set up the lazy.nvim installation path
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- Clone lazy.nvim if it doesn't exist
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end

-- Add lazy.nvim to the runtime path
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- Plugin Configuration
-- ============================================================================

require("lazy").setup({
    -- ========================================================================
    -- Core Settings
    -- ========================================================================

    rocks = {
        enabled = false, -- Disable luarocks integration to fix warnings
    },

    -- ========================================================================
    -- Plugin Specifications
    -- ========================================================================

    spec = {
        -- --------------------------------------------------------------------
        -- LazyVim Base
        -- --------------------------------------------------------------------

        -- Core LazyVim with Catppuccin Mocha colorscheme
        { "LazyVim/LazyVim", import = "lazyvim.plugins", opts = { colorscheme = "catppuccin-mocha" } },

        -- --------------------------------------------------------------------
        -- Testing
        -- --------------------------------------------------------------------

        { import = "lazyvim.plugins.extras.test.core" },

        -- --------------------------------------------------------------------
        -- Language Support
        -- --------------------------------------------------------------------

        -- Nix
        { import = "lazyvim.plugins.extras.lang.nix" },

        -- Python with custom test runner configuration
        {
            import = "lazyvim.plugins.extras.lang.python",
            opts = {
                adapters = {
                    ["neotest-python"] = {
                        runner = { "pytest", "uv run pytest" },
                        python = { "python", "python3" },
                    },
                },
            },
        },

        -- SQL
        { import = "lazyvim.plugins.extras.lang.sql" },

        -- Zig
        { import = "lazyvim.plugins.extras.lang.zig" },

        -- Go
        { import = "lazyvim.plugins.extras.lang.go" },

        -- C/C++ (clangd)
        { import = "lazyvim.plugins.extras.lang.clangd" },

        -- Svelte
        { import = "lazyvim.plugins.extras.lang.svelte" },

        -- Rust
        { import = "lazyvim.plugins.extras.lang.rust" },

        -- Elixir
        { import = "lazyvim.plugins.extras.lang.elixir" },

        -- Tailwind CSS
        { import = "lazyvim.plugins.extras.lang.tailwind" },

        -- --------------------------------------------------------------------
        -- Coding Enhancements
        -- --------------------------------------------------------------------

        { import = "lazyvim.plugins.extras.coding.mini-surround" },

        -- --------------------------------------------------------------------
        -- Editor Enhancements
        -- --------------------------------------------------------------------

        { import = "lazyvim.plugins.extras.editor.mini-diff" },
        { import = "lazyvim.plugins.extras.editor.mini-move" },

        -- --------------------------------------------------------------------
        -- Utilities
        -- --------------------------------------------------------------------

        -- Mini hipatterns for Tailwind color highlighting
        { import = "lazyvim.plugins.extras.util.mini-hipatterns" },

        -- --------------------------------------------------------------------
        -- Custom Plugins
        -- --------------------------------------------------------------------

        -- Import custom plugins from lua/plugins directory
        { import = "plugins" },

        -- --------------------------------------------------------------------
        -- Plugin Overrides
        -- --------------------------------------------------------------------

        -- Noice.nvim: Disable hover messages when not available
        {
            "folke/noice.nvim",
            opts = {
                lsp = {
                    hover = {
                        -- Don't show message if hover is not available (e.g., shift+k on TypeScript)
                        silent = true,
                    },
                },
            },
        },

        -- Tmux Navigator: Seamless navigation between vim and tmux panes
        {
            "christoomey/vim-tmux-navigator",
            cmd = {
                "TmuxNavigateLeft",
                "TmuxNavigateDown",
                "TmuxNavigateUp",
                "TmuxNavigateRight",
                "TmuxNavigatePrevious",
            },
            keys = {
                { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
                { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
                { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
                { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
                { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
            },
        },

        -- Render Markdown: Enhanced markdown rendering
        {
            "MeanderingProgrammer/render-markdown.nvim",
            opts = {
                win_options = {
                    conceallevel = { default = 0, rendered = 3 },
                },
                -- Disable LaTeX support since latex2text is not installed
                latex = {
                    enabled = false,
                },
            },
        },

        -- --------------------------------------------------------------------
        -- Disabled Plugins
        -- --------------------------------------------------------------------

        { "nvim-neo-tree/neo-tree.nvim", enabled = false },
        { "akinsho/bufferline.nvim", enabled = false },
        { "nvimdev/dashboard-nvim", enabled = false },
    },

    -- ========================================================================
    -- Plugin Defaults
    -- ========================================================================

    defaults = {
        -- By default, only LazyVim plugins will be lazy-loaded
        -- Custom plugins will load during startup
        -- Set to true to have all custom plugins lazy-loaded by default
        lazy = false,

        -- Always use the latest git commit
        -- It's recommended to leave version=false since many plugins
        -- have outdated releases that may break Neovim
        version = false,
    },

    -- ========================================================================
    -- Update Checker
    -- ========================================================================

    checker = {
        enabled = true, -- Check for plugin updates periodically
        notify = false, -- Don't notify on update
    },

    -- ========================================================================
    -- Performance Optimizations
    -- ========================================================================

    performance = {
        rtp = {
            -- Disable unused runtime path plugins
            disabled_plugins = {
                "gzip",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
})
