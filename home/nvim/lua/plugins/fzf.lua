return {
	{
		"fzf-lua",
		lazy = false,
		after = function()
			local ok, fzf = pcall(require, "fzf-lua")
			if not ok then
				vim.notify("fzf-lua failed to load", vim.log.levels.ERROR)
				return
			end

			local config = fzf.config
			local actions = fzf.actions

			-- Keymaps like LazyVim
			config.defaults.keymap.fzf["ctrl-q"] = "select-all+accept"
			config.defaults.keymap.fzf["ctrl-u"] = "half-page-up"
			config.defaults.keymap.fzf["ctrl-d"] = "half-page-down"
			config.defaults.keymap.fzf["ctrl-x"] = "jump"
			config.defaults.keymap.fzf["ctrl-f"] = "preview-page-down"
			config.defaults.keymap.fzf["ctrl-b"] = "preview-page-up"
			config.defaults.keymap.builtin["<c-f>"] = "preview-page-down"
			config.defaults.keymap.builtin["<c-b>"] = "preview-page-up"

			-- Setup with LazyVim-style config
			fzf.setup({
				"default-title",
				fzf_colors = true,
				fzf_opts = {
					["--no-scrollbar"] = true,
				},
				defaults = {
					formatter = "path.dirname_first",
					silent = true, -- Suppress "no results" messages
				},
				winopts = {
					width = 0.8,
					height = 0.8,
					row = 0.5,
					col = 0.5,
					preview = {
						scrollchars = { "┃", "" },
					},
				},
				files = {
					cwd_prompt = false,
					actions = {
						["alt-i"] = { actions.toggle_ignore },
						["alt-h"] = { actions.toggle_hidden },
					},
				},
				grep = {
					actions = {
						["alt-i"] = { actions.toggle_ignore },
						["alt-h"] = { actions.toggle_hidden },
					},
				},
			})

			-- Register for vim.ui.select
			fzf.register_ui_select()

			-- Setup frecency (file ranking by frequency + recency)
			require("fzf-lua-frecency").setup()

			-- Set up keymaps directly (LazyVim style)
			local map = vim.keymap.set

			-- Find
			map("n", "<leader><leader>", function()
				require("fzf-lua-frecency").frecency({ cwd_only = true, display_score = false })
			end, { desc = "Find Files (frecency)" })
			map(
				"n",
				"<leader>,",
				"<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>",
				{ desc = "Switch Buffer" }
			)
			map("n", "<leader>/", "<cmd>FzfLua live_grep<cr>", { desc = "Grep (Root Dir)" })
			map("n", "<leader>:", "<cmd>FzfLua command_history<cr>", { desc = "Command History" })

			-- find
			map("n", "<leader>fb", "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>", { desc = "Buffers" })
			map("n", "<leader>ff", function()
				require("fzf-lua-frecency").frecency({ cwd_only = true, display_score = false })
			end, { desc = "Find Files (frecency)" })
			map("n", "<leader>fF", "<cmd>FzfLua files<cr>", { desc = "Find Files (all)" })
			map("n", "<leader>fg", "<cmd>FzfLua git_files<cr>", { desc = "Find Files (git-files)" })
			map("n", "<leader>fr", "<cmd>FzfLua oldfiles<cr>", { desc = "Recent" })

			-- git
			map("n", "<leader>gc", "<cmd>FzfLua git_commits<CR>", { desc = "Commits" })
			map("n", "<leader>gs", "<cmd>FzfLua git_status<CR>", { desc = "Status" })
			map("n", "<leader>gb", "<cmd>FzfLua git_branches<CR>", { desc = "Branches" })

			-- search
			map("n", '<leader>s"', "<cmd>FzfLua registers<cr>", { desc = "Registers" })
			map("n", "<leader>sa", "<cmd>FzfLua autocmds<cr>", { desc = "Auto Commands" })
			map("n", "<leader>sb", "<cmd>FzfLua grep_curbuf<cr>", { desc = "Buffer" })
			map("n", "<leader>sc", "<cmd>FzfLua command_history<cr>", { desc = "Command History" })
			map("n", "<leader>sC", "<cmd>FzfLua commands<cr>", { desc = "Commands" })
			map("n", "<leader>sd", "<cmd>FzfLua diagnostics_document<cr>", { desc = "Document Diagnostics" })
			map("n", "<leader>sD", "<cmd>FzfLua diagnostics_workspace<cr>", { desc = "Workspace Diagnostics" })
			map("n", "<leader>sg", "<cmd>FzfLua live_grep<cr>", { desc = "Grep (Root Dir)" })
			map("n", "<leader>sh", "<cmd>FzfLua help_tags<cr>", { desc = "Help Pages" })
			map("n", "<leader>sH", "<cmd>FzfLua highlights<cr>", { desc = "Search Highlight Groups" })
			map("n", "<leader>sj", "<cmd>FzfLua jumps<cr>", { desc = "Jumplist" })
			map("n", "<leader>sk", "<cmd>FzfLua keymaps<cr>", { desc = "Key Maps" })
			map("n", "<leader>sl", "<cmd>FzfLua loclist<cr>", { desc = "Location List" })
			map("n", "<leader>sM", "<cmd>FzfLua man_pages<cr>", { desc = "Man Pages" })
			map("n", "<leader>sm", "<cmd>FzfLua marks<cr>", { desc = "Jump to Mark" })
			map("n", "<leader>sR", "<cmd>FzfLua resume<cr>", { desc = "Resume" })
			map("n", "<leader>sq", "<cmd>FzfLua quickfix<cr>", { desc = "Quickfix List" })
			map("n", "<leader>sw", "<cmd>FzfLua grep_cword<cr>", { desc = "Word (Root Dir)" })
			map("x", "<leader>sw", "<cmd>FzfLua grep_visual<cr>", { desc = "Selection (Root Dir)" })

			-- LSP
			map("n", "<leader>ss", "<cmd>FzfLua lsp_document_symbols<cr>", { desc = "Goto Symbol" })
			map("n", "<leader>sS", "<cmd>FzfLua lsp_live_workspace_symbols<cr>", { desc = "Goto Symbol (Workspace)" })
			map(
				"n",
				"gd",
				"<cmd>FzfLua lsp_definitions jump1=true ignore_current_line=true<cr>",
				{ desc = "Goto Definition" }
			)
			map(
				"n",
				"gr",
				"<cmd>FzfLua lsp_references jump1=true ignore_current_line=true<cr>",
				{ desc = "References" }
			)
			map(
				"n",
				"gI",
				"<cmd>FzfLua lsp_implementations jump1=true ignore_current_line=true<cr>",
				{ desc = "Goto Implementation" }
			)
			map(
				"n",
				"gy",
				"<cmd>FzfLua lsp_typedefs jump1=true ignore_current_line=true<cr>",
				{ desc = "Goto T[y]pe Definition" }
			)

			-- Config files
			map("n", "<leader>fc", function()
				fzf.files({ cwd = vim.fn.stdpath("config") })
			end, { desc = "Find Config File" })
		end,
	},
}
