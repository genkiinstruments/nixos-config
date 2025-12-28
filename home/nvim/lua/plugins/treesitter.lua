return {
	-- Treesitter (parsers + queries)
	{
		"nvim-treesitter",
		lazy = false,
		after = function()
			-- Incremental selection
			local ok, inc_sel = pcall(require, "nvim-treesitter.incremental_selection")
			if ok then
				vim.keymap.set("n", "<C-space>", inc_sel.init_selection, { desc = "Init selection" })
				vim.keymap.set("x", "<C-space>", inc_sel.node_incremental, { desc = "Increment selection" })
				vim.keymap.set("x", "<bs>", inc_sel.node_decremental, { desc = "Decrement selection" })
			end
		end,
	},

	{
		"nvim-treesitter-textobjects",
		event = { "BufReadPre", "BufNewFile" },
		after = function()
			---@diagnostic disable-next-line: missing-fields
			require("nvim-treesitter.configs").setup({
				highlight = { enable = true },
				indent = { enable = true },
				textobjects = {
					move = {
						enable = true,
						set_jumps = true,
						goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
						goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
						goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner" },
						goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[A"] = "@parameter.inner" },
					},
				},
			})

			vim.api.nvim_set_hl(0, "TreesitterContextBottom", { underline = false })
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
