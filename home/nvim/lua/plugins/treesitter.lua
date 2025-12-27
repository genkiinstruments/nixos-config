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

	-- Mini.ai for textobjects (works with treesitter, no deprecated API dependency)
	{
		"mini.ai",
		event = { "BufReadPre", "BufNewFile" },
		after = function()
			local ai = require("mini.ai")
			ai.setup({
				n_lines = 500,
				custom_textobjects = {
					-- Function
					f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
					-- Class
					c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
					-- Block
					o = ai.gen_spec.treesitter({
						a = { "@block.outer", "@conditional.outer", "@loop.outer" },
						i = { "@block.inner", "@conditional.inner", "@loop.inner" },
					}),
					-- Argument/parameter
					a = ai.gen_spec.treesitter({ a = "@parameter.outer", i = "@parameter.inner" }),
					-- Comment
					x = ai.gen_spec.treesitter({ a = "@comment.outer", i = "@comment.inner" }),
				},
			})

			-- Remap keys for next/prev textobject (LazyVim style)
			local function map_move(key, query, desc)
				vim.keymap.set({ "n", "x", "o" }, key, function()
					require("mini.ai").move_cursor("left", "a", query, { search_method = "next" })
				end, { desc = desc })
			end

			-- Add goto keymaps
			vim.keymap.set({ "n", "x", "o" }, "]f", function()
				require("mini.ai").move_cursor("right", "a", "f", { search_method = "next" })
			end, { desc = "Next function" })
			vim.keymap.set({ "n", "x", "o" }, "[f", function()
				require("mini.ai").move_cursor("left", "a", "f", { search_method = "prev" })
			end, { desc = "Prev function" })
			vim.keymap.set({ "n", "x", "o" }, "]c", function()
				require("mini.ai").move_cursor("right", "a", "c", { search_method = "next" })
			end, { desc = "Next class" })
			vim.keymap.set({ "n", "x", "o" }, "[c", function()
				require("mini.ai").move_cursor("left", "a", "c", { search_method = "prev" })
			end, { desc = "Prev class" })
			vim.keymap.set({ "n", "x", "o" }, "]a", function()
				require("mini.ai").move_cursor("right", "a", "a", { search_method = "next" })
			end, { desc = "Next argument" })
			vim.keymap.set({ "n", "x", "o" }, "[a", function()
				require("mini.ai").move_cursor("left", "a", "a", { search_method = "prev" })
			end, { desc = "Prev argument" })
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
