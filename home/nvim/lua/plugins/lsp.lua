-- Global LSP autocmds (outside plugin spec)
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client and client.server_capabilities.inlayHintProvider then
			vim.lsp.inlay_hint.enable(true, { buffer = args.buf })
		end
	end,
})

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client and client.name == "rust_analyzer" then
			vim.fn.matchadd("ErrorMsg", "\\<SAFETY\\ze:")
			vim.api.nvim_set_hl(0, "@lsp.typemod.operator.unsafe.rust", { link = "ErrorMsg" })
			vim.api.nvim_set_hl(0, "@lsp.typemod.function.unsafe.rust", { link = "ErrorMsg" })
			vim.api.nvim_set_hl(0, "@lsp.typemod.method.unsafe.rust", { link = "ErrorMsg" })
		end
	end,
})

return {
	-- LSP config (using Neovim 0.11+ vim.lsp API)
	{
		"nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		after = function()
			-- Find typescript-svelte-plugin path from svelte-language-server
			local function get_svelte_plugin_path()
				local svelteserver = vim.fn.exepath("svelteserver")
				if svelteserver ~= "" then
					-- Path: .../bin/svelteserver -> .../lib/node_modules/svelte-language-server/packages/typescript-plugin
					local base = svelteserver:gsub("/bin/svelteserver$", "")
					return base .. "/lib/node_modules/svelte-language-server/packages/typescript-plugin"
				end
				return nil
			end

			-- Custom config for ts_ls with Svelte plugin
			local svelte_plugin_path = get_svelte_plugin_path()
			if svelte_plugin_path then
				vim.lsp.config("ts_ls", {
					init_options = {
						plugins = {
							{
								name = "typescript-svelte-plugin",
								location = svelte_plugin_path,
							},
						},
					},
				})
			end

			-- Custom config for nil_ls (Nix) with nixfmt
			vim.lsp.config("nil_ls", {
				settings = {
					["nil"] = {
						formatting = { command = { "nixfmt" } },
					},
				},
			})

			-- Custom config for expert (Elixir LSP - not yet in nvim-lspconfig)
			vim.lsp.config("expert", {
				cmd = { "expert", "--stdio" },
				filetypes = { "elixir", "eelixir", "heex", "surface" },
				root_markers = { "mix.exs", ".git" },
			})

			-- Custom config for emmet_language_server to include Svelte and other frameworks
			vim.lsp.config("emmet_language_server", {
				filetypes = {
					"html",
					"css",
					"scss",
					"less",
					"javascriptreact",
					"typescriptreact",
					"svelte",
					"vue",
					"astro",
				},
			})

			-- Enable LSP servers (uses built-in configs from nvim-lspconfig)
			vim.lsp.enable("nil_ls") -- Nix
			vim.lsp.enable("lua_ls") -- Lua
			vim.lsp.enable("ts_ls") -- TypeScript/JavaScript
			vim.lsp.enable("pyright") -- Python
			vim.lsp.enable("gopls") -- Go
			vim.lsp.enable("expert") -- Elixir
			vim.lsp.enable("html") -- HTML
			vim.lsp.enable("cssls") -- CSS
			vim.lsp.enable("jsonls") -- JSON
			vim.lsp.enable("svelte") -- Svelte

			-- Svelte organize imports keybinding
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client and client.name == "svelte" then
						vim.keymap.set("n", "<leader>co", function()
							vim.lsp.buf.code_action({
								apply = true,
								context = { only = { "source.organizeImports" }, diagnostics = {} },
							})
						end, { buffer = args.buf, desc = "Organize Imports" })
					end
				end,
			})
			vim.lsp.enable("emmet_language_server") -- Emmet
		end,
	},

	-- Rust (rustaceanvim handles its own lsp)
	{
		"rustaceanvim",
		event = "VimEnter",
	},

	-- Crates.nvim for Cargo.toml
	{
		"crates.nvim",
		event = "BufRead Cargo.toml",
		after = function()
			require("crates").setup({})
		end,
	},

	-- Lazydev for Neovim Lua development
	{
		"lazydev.nvim",
		ft = "lua",
		after = function()
			require("lazydev").setup()
		end,
	},

	-- Fidget for LSP progress
	{
		"fidget.nvim",
		event = "LspAttach",
		after = function()
			require("fidget").setup()
		end,
	},

	-- Live rename (inline LSP rename)
	{
		"live-rename.nvim",
		keys = {
			{
				"grn",
				function()
					require("live-rename").rename()
				end,
				desc = "LSP Rename",
			},
		},
	},

	-- Snippets
	{
		"LuaSnip",
		event = "InsertEnter",
		after = function()
			local luasnip = require("luasnip")
			luasnip.setup({})

			-- Load friendly-snippets
			require("luasnip.loaders.from_vscode").lazy_load()

			-- Load custom snippets from config/snippets directory
			require("luasnip.loaders.from_vscode").lazy_load({
				paths = { vim.fn.stdpath("config") .. "/snippets" },
			})
		end,
	},

	-- Blink completion
	{
		"blink.cmp",
		event = "InsertEnter",
		after = function()
			require("blink.cmp").setup({
				keymap = {
					preset = "default",
					["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
					["<C-e>"] = { "hide" },
					["<CR>"] = { "accept", "fallback" },
					["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
					["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
					["<C-n>"] = { "select_next", "fallback" },
					["<C-p>"] = { "select_prev", "fallback" },
					["<Up>"] = { "select_prev", "fallback" },
					["<Down>"] = { "select_next", "fallback" },
					["<C-d>"] = { "scroll_documentation_down", "fallback" },
					["<C-u>"] = { "scroll_documentation_up", "fallback" },
				},
				appearance = {
					use_nvim_cmp_as_default = true,
					nerd_font_variant = "mono",
				},
				sources = {
					default = { "lsp", "snippets", "path", "buffer" },
				},
				snippets = { preset = "luasnip" },
				fuzzy = {
					implementation = "lua",
				},
			})
		end,
	},

	-- Conform for formatting
	{
		"conform.nvim",
		event = "BufWritePre",
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>cf",
				function()
					require("conform").format({ async = true, lsp_fallback = true })
				end,
				desc = "Format buffer",
			},
		},
		after = function()
			require("conform").setup({
				formatters_by_ft = {
					lua = { "stylua" },
					nix = { "nixfmt" },
					python = { "ruff_format" },
					rust = { "rustfmt" },
					go = { "gofmt" },
					javascript = { "oxfmt" },
					typescript = { "oxfmt" },
					-- oxfmt only supports JS/TS for now, prettierd for others
					svelte = { "prettierd" },
					json = { "prettierd" },
					html = { "prettierd" },
					css = { "prettierd" },
					markdown = { "prettierd" },
				},
				format_on_save = function(bufnr)
					if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
						return
					end
					return { timeout_ms = 500, lsp_format = "fallback" }
				end,
			})

			vim.api.nvim_create_user_command("FormatDisable", function(args)
				if args.bang then
					vim.b.disable_autoformat = true
				else
					vim.g.disable_autoformat = true
				end
			end, {
				desc = "Disable autoformat-on-save",
				bang = true,
			})

			vim.api.nvim_create_user_command("FormatEnable", function()
				vim.b.disable_autoformat = false
				vim.g.disable_autoformat = false
			end, {
				desc = "Re-enable autoformat-on-save",
			})
		end,
	},

	-- Nvim-lint for linting
	{
		"nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		after = function()
			local lint = require("lint")
			lint.linters_by_ft = {
				python = { "ruff" },
			}
			vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
				callback = function()
					lint.try_lint()
				end,
			})
		end,
	},
}
