return {
	-- mini.ai for better textobjects (arguments, brackets, quotes, etc.)
	{
		"mini.ai",
		lazy = false,
		after = function()
			local ai = require("mini.ai")
			ai.setup({
				n_lines = 500,
				-- Disable f, c, a as nvim-treesitter-textobjects handles them (supports #make-range!)
				custom_textobjects = {
					f = false,
					c = false,
					a = false,
					o = ai.gen_spec.treesitter({ -- code block
						a = { "@block.outer", "@conditional.outer", "@loop.outer" },
						i = { "@block.inner", "@conditional.inner", "@loop.inner" },
					}),
					t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
					d = { "%f[%d]%d+" }, -- digits
					e = { -- word with case (camelCase, snake_case, etc.)
						{
							"%u[%l%d]+%f[^%l%d]",
							"%f[%S][%l%d]+%f[^%l%d]",
							"%f[%P][%l%d]+%f[^%l%d]",
							"^[%l%d]+%f[^%l%d]",
						},
						"^().*()$",
					},
					g = function(ai_type) -- entire buffer
						local start_line, end_line = 1, vim.fn.line("$")
						if ai_type == "i" then
							-- Skip first and last blank lines for `ig`
							local first_nonblank = vim.fn.nextnonblank(start_line)
							local last_nonblank = vim.fn.prevnonblank(end_line)
							if first_nonblank == 0 or last_nonblank == 0 then
								return { from = { line = start_line, col = 1 } }
							end
							start_line, end_line = first_nonblank, last_nonblank
						end
						local to_col = math.max(vim.fn.getline(end_line):len(), 1)
						return { from = { line = start_line, col = 1 }, to = { line = end_line, col = to_col } }
					end,
					u = ai.gen_spec.function_call(), -- function call
					U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- function call without dot
				},
			})
		end,
	},

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
			-- Normal and terminal mode mappings
			for _, mode in ipairs({ "n", "t" }) do
				vim.keymap.set(mode, "<C-h>", "<cmd>TmuxNavigateLeft<CR>", { silent = true })
				vim.keymap.set(mode, "<C-j>", "<cmd>TmuxNavigateDown<CR>", { silent = true })
				vim.keymap.set(mode, "<C-k>", "<cmd>TmuxNavigateUp<CR>", { silent = true })
				vim.keymap.set(mode, "<C-l>", "<cmd>TmuxNavigateRight<CR>", { silent = true })
			end
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
}
