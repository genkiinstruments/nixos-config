return {
	-- Auto close/rename HTML tags
	{
		"nvim-ts-autotag",
		event = { "BufReadPre", "BufNewFile" },
		ft = {
			"html",
			"javascript",
			"typescript",
			"javascriptreact",
			"typescriptreact",
			"svelte",
			"vue",
			"tsx",
			"jsx",
			"xml",
			"markdown",
			"heex",
			"elixir",
			"eelixir",
		},
		after = function()
			require("nvim-ts-autotag").setup()
		end,
	},

	-- Treesitter context (sticky header showing current function/class)
	{
		"nvim-treesitter-context",
		event = { "BufReadPre", "BufNewFile" },
		after = function()
			require("treesitter-context").setup({
				max_lines = 3,
			})

			-- Toggle context
			vim.keymap.set("n", "<leader>ut", function()
				require("treesitter-context").toggle()
			end, { desc = "Toggle Treesitter Context" })

			-- Go to context (jump to the context header)
			vim.keymap.set("n", "[C", function()
				require("treesitter-context").go_to_context()
			end, { desc = "Go to context" })
		end,
	},

	-- Markdown rendering
	{
		"render-markdown.nvim",
		ft = "markdown",
		after = function()
			local ok, rm = pcall(require, "render-markdown")
			if ok then
				rm.setup({ latex = { enabled = false } })
			end
		end,
	},
}
