return {
	-- Catppuccin theme
	{
		"catppuccin-nvim",
		lazy = false,
		priority = 1000,
		after = function()
			require("catppuccin").setup({
				integrations = {
					snacks = true,
					treesitter_context = true,
					gitsigns = true,
					fzf = true,
				},
			})
		end,
	},

	-- Statusline
	{
		"lualine.nvim",
		lazy = false,
		after = function()
			require("lualine").setup({
				options = {
					theme = "catppuccin",
					globalstatus = true,
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = { "filename" },
					lualine_x = {
						{
							function()
								local clients = vim.lsp.get_clients({ bufnr = 0 })
								if #clients == 0 then
									return ""
								end
								local names = {}
								for _, client in ipairs(clients) do
									table.insert(names, client.name)
								end
								return " " .. table.concat(names, ", ")
							end,
						},
						"encoding",
						"fileformat",
						"filetype",
					},
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
			})
		end,
	},

	-- Which-key
	{
		"which-key.nvim",
		event = "DeferredUIEnter",
		after = function()
			require("which-key").setup({
				delay = 300,
			})
		end,
	},

	-- Noice (cmdline, messages, notifications UI)
	{
		"noice.nvim",
		lazy = false,
		after = function()
			require("noice").setup({
				lsp = {
					override = {
						["vim.lsp.util.convert_input_to_markdown_lines"] = true,
						["vim.lsp.util.stylize_markdown"] = true,
						["cmp.entry.get_documentation"] = true,
					},
					hover = { silent = true },
				},
				presets = {
					bottom_search = true,
					command_palette = true,
					long_message_to_split = true,
					lsp_doc_border = true,
				},
			})
		end,
	},

	-- Icons
	{
		"nvim-web-devicons",
		lazy = false,
		after = function()
			require("nvim-web-devicons").setup()
		end,
	},

	-- Snacks (dashboard + utilities)
	{
		"snacks.nvim",
		lazy = false,
		after = function()
			require("snacks").setup({
				dashboard = {
					enabled = true,
					preset = {
						keys = {
							{ icon = " ", key = "f", desc = "Find File", action = ":FzfLua files" },
							{ icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
							{ icon = " ", key = "g", desc = "Find Text", action = ":FzfLua live_grep" },
							{ icon = " ", key = "r", desc = "Recent Files", action = ":FzfLua oldfiles" },
							{
								icon = " ",
								key = "c",
								desc = "Config",
								action = ":lua require('fzf-lua').files({cwd = vim.fn.stdpath('config')})",
							},
							{ icon = "󰒲 ", key = "u", desc = "Update Plugins", action = ":PackUpdate" },
							{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
						},
						header = [[
███╗   ███╗██╗   ██╗██╗███╗   ███╗
████╗ ████║██║   ██║██║████╗ ████║
██╔████╔██║██║   ██║██║██╔████╔██║
██║╚██╔╝██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚═╝ ██║ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝     ╚═╝  ╚═══╝  ╚═╝╚═╝     ╚═╝]],
					},
					sections = {
						{ section = "header", padding = 2 },
						{ section = "keys", gap = 1, padding = 2 },
					},
				},
				-- Disabled features
				explorer = { enabled = false },
				picker = { enabled = false },
				statuscolumn = { enabled = false },
				quickfile = { enabled = false },
				-- Enabled features
				bigfile = { enabled = true },
				notifier = { enabled = true },
				indent = { enabled = true },
				words = { enabled = true },
				terminal = { enabled = true },
				lazygit = { enabled = true },
				git = { enabled = true },
				gitbrowse = { enabled = true },
				scratch = { enabled = true },
				zen = { enabled = true },
				bufdelete = { enabled = true },
			})
		end,
	},
}
