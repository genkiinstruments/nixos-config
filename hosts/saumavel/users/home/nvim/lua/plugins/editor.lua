return {
	-- Oil file explorer
	{
		"oil.nvim",
		keys = {
			{ "-", "<cmd>Oil<CR>", desc = "Open parent directory" },
			{ "_", "<cmd>Oil .<CR>", desc = "Open nvim root directory" },
		},
		after = function()
			require("oil").setup({
				columns = {
					"icon",
					"permissions",
					"size",
					{ "mtime", highlight = "Comment", format = "%T %y-%m-%d" },
				},
				skip_confirm_for_simple_edits = true,
				view_options = {
					show_hidden = true,
				},
				delete_to_trash = true,
				default_file_explorer = false,
				keymaps = {
					["<ESC>"] = "actions.close",
					["q"] = "actions.close",
					["?"] = "actions.show_help",
					["<CR>"] = "actions.select",
					["<C-v>"] = "actions.select_vsplit",
					["<C-x>"] = "actions.select_split",
					["K"] = "actions.preview",
					["<C-r>"] = "actions.refresh",
					["<BS>"] = "actions.parent",
					["~"] = "actions.open_cwd",
					["`"] = "actions.cd",
				},
			})
		end,
	},

	-- Flash for quick navigation
	{
		"flash.nvim",
		keys = {
			{
				"s",
				function()
					require("flash").jump()
				end,
				mode = { "n", "x", "o" },
				desc = "Flash",
			},
			{
				"S",
				function()
					require("flash").treesitter()
				end,
				mode = { "n", "x", "o" },
				desc = "Flash Treesitter",
			},
		},
		after = function()
			require("flash").setup()
		end,
	},

	-- Surround
	{
		"nvim-surround",
		event = "BufEnter",
		after = function()
			require("nvim-surround").setup()
		end,
	},

	-- Autopairs
	{
		"nvim-autopairs",
		event = "InsertEnter",
		after = function()
			require("nvim-autopairs").setup()
		end,
	},

	-- Tmux navigator
	{
		"vim-tmux-navigator",
		lazy = false,
		after = function()
			vim.g.tmux_navigator_no_mappings = 1
			vim.keymap.set("n", "<C-h>", "<cmd>TmuxNavigateLeft<CR>", { silent = true })
			vim.keymap.set("n", "<C-j>", "<cmd>TmuxNavigateDown<CR>", { silent = true })
			vim.keymap.set("n", "<C-k>", "<cmd>TmuxNavigateUp<CR>", { silent = true })
			vim.keymap.set("n", "<C-l>", "<cmd>TmuxNavigateRight<CR>", { silent = true })
		end,
	},

	-- Undotree
	{
		"undotree",
		keys = {
			{ "<leader>gu", "<cmd>UndotreeToggle<CR>", desc = "Toggle undo tree" },
		},
	},

	-- Gitsigns
	{
		"gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		after = function()
			require("gitsigns").setup({
				signs = {
					add = { text = "▎" },
					change = { text = "▎" },
					delete = { text = "" },
					topdelete = { text = "" },
					changedelete = { text = "▎" },
				},
			})
		end,
	},

	-- Todo comments
	{
		"todo-comments.nvim",
		event = { "BufReadPre", "BufNewFile" },
		after = function()
			require("todo-comments").setup()
		end,
	},

	-- Saumavel: Mini.diff for inline git diff
	{
		"mini.diff",
		event = { "BufReadPre", "BufNewFile" },
		after = function()
			require("mini.diff").setup({
				view = {
					style = "sign",
					signs = { add = "▎", change = "▎", delete = "" },
				},
			})
		end,
	},

	-- Saumavel: Mini.move for moving lines/blocks
	{
		"mini.move",
		event = { "BufReadPre", "BufNewFile" },
		after = function()
			require("mini.move").setup({
				mappings = {
					-- Move visual selection in Visual mode
					left = "<M-h>",
					right = "<M-l>",
					down = "<M-j>",
					up = "<M-k>",
					-- Move current line in Normal mode
					line_left = "<M-h>",
					line_right = "<M-l>",
					line_down = "<M-j>",
					line_up = "<M-k>",
				},
			})
		end,
	},
}
