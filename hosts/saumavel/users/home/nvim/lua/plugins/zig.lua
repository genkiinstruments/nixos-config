-- ============================================================================
-- Zig Language Support Configuration
-- ============================================================================
-- Complete Zig development setup with LSP, debugging, testing, and formatting
return {
    -- ========================================================================
    -- Zig Tools
    -- ========================================================================

    -- Zig-specific utilities and integrations
    -- Note: Not supported on nixpkgs
    {
        "NTBBloodbath/zig-tools.nvim",
        ft = "zig",
        opts = {},
        dependencies = {
            {
                "akinsho/toggleterm.nvim",
            },
        },
    },

    -- ========================================================================
    -- Mason Package Manager
    -- ========================================================================
    -- Ensure Zig language server and debugger are installed
    {
        "mason-org/mason.nvim",
        optional = true,
        opts = function(_, opts)
            if type(opts.ensure_installed) == "table" then
                vim.list_extend(opts.ensure_installed, {
                    "zls", -- Zig Language Server
                    "codelldb", -- LLDB-based debugger
                })
            end
        end,
    },

    -- ========================================================================
    -- LSP Configuration
    -- ========================================================================
    -- Zig Language Server (ZLS) setup
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                zls = {
                    setup = {
                        zls = function(_, opts)
                            -- Integrate with zig-tools.nvim
                            local zig_tools_opts = require("lazyvim.util").opts("zig-tools.nvim")
                            require("zig-tools").setup(
                                vim.tbl_deep_extend("force", zig_tools_opts or {}, { server = opts })
                            )
                            return true
                        end,
                    },
                },
            },
        },
    },

    -- ========================================================================
    -- Testing Framework
    -- ========================================================================
    -- Neotest integration for Zig
    {
        "nvim-neotest/neotest",
        optional = true,
        dependencies = {
            "lawrence-laz/neotest-zig",
        },
        opts = {
            adapters = {
                ["neotest-zig"] = {},
            },
        },
    },

    -- ========================================================================
    -- Debugging (DAP)
    -- ========================================================================
    -- Debug Adapter Protocol configuration for Zig
    {
        "mfussenegger/nvim-dap",
        optional = true,
        opts = function()
            local dap = require("dap")

            -- Zig debugging configuration
            dap.configurations.zig = {
                {
                    name = "Zig Run",
                    type = "codelldb",
                    request = "launch",

                    -- Build and find the executable
                    program = function()
                        -- Build the project
                        os.execute("zig build")

                        -- Find the main executable (excluding tests)
                        local command = "find ! -type d -path './zig-out/bin/*' | grep -v 'Test' | sed 's#.*/##'"
                        local bin_location = io.popen(command, "r")

                        if bin_location ~= nil then
                            return "zig-out/bin/" .. bin_location:read("*a"):gsub("[\n\r]", "")
                        else
                            return ""
                        end
                    end,

                    cwd = "${workspaceFolder}",
                    stopOnEntry = false,

                    -- Prompt for command-line arguments
                    args = function()
                        local argv = {}
                        arg = vim.fn.input(string.format("Arguments: "))
                        for a in string.gmatch(arg, "%S+") do
                            table.insert(argv, a)
                        end
                        return argv
                    end,
                },
            }
        end,
    },

    -- ========================================================================
    -- Formatting
    -- ========================================================================
    -- Conform.nvim formatter configuration
    {
        "stevearc/conform.nvim",
        optional = true,
        opts = {
            formatters_by_ft = {
                zig = { "zigfmt" }, -- Use zig fmt for formatting
            },
        },
    },
}
