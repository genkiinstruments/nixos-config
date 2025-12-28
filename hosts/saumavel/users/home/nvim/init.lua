-- Load core config
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- Hook for post-install updates
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(event)
		if event.data.updated then
			vim.cmd.TSUpdate()
		end
	end,
})

-- Add all plugins via vim.pack (neovim 0.12+ built-in plugin manager)
-- These will be cloned from GitHub and pinned via nvim-pack-lock.json
vim.pack.add({
	-- Core
	"https://github.com/lumen-oss/lz.n",
	"https://github.com/nvim-lua/plenary.nvim",

	-- UI
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/nvim-lualine/lualine.nvim",
	"https://github.com/folke/which-key.nvim",
	"https://github.com/folke/snacks.nvim",
	"https://github.com/folke/noice.nvim", -- Saumavel: noice for cmdline/messages/notifications

	-- Editor
	"https://github.com/stevearc/oil.nvim",
	"https://github.com/folke/flash.nvim",
	"https://github.com/kylechui/nvim-surround",
	"https://github.com/windwp/nvim-autopairs",
	"https://github.com/christoomey/vim-tmux-navigator",
	"https://github.com/mbbill/undotree",
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/folke/todo-comments.nvim",

	-- Mini plugins (saumavel extras)
	"https://github.com/echasnovski/mini.ai",
	"https://github.com/echasnovski/mini.diff",
	"https://github.com/echasnovski/mini.move",
	"https://github.com/echasnovski/mini.hipatterns",

	-- Fuzzy finding (fzf-lua like LazyVim)
	"https://github.com/ibhagwan/fzf-lua",

	-- LSP & Completion
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/folke/lazydev.nvim",
	"https://github.com/j-hui/fidget.nvim",
	"https://github.com/saecki/live-rename.nvim",

	-- Treesitter
	"https://github.com/nvim-treesitter/nvim-treesitter",
	"https://github.com/nvim-treesitter/nvim-treesitter-context",
	"https://github.com/nvim-treesitter/nvim-treesitter-textobjects",

	-- Formatting & Linting
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/mfussenegger/nvim-lint",

	-- Language specific
	"https://github.com/mrcjkb/rustaceanvim",
	"https://github.com/saecki/crates.nvim",

	-- Markdown
	"https://github.com/MeanderingProgrammer/render-markdown.nvim",

	-- Snippets
	"https://github.com/L3MON4D3/LuaSnip",
	"https://github.com/rafamadriz/friendly-snippets",

	-- Noice dependencies
	"https://github.com/MunifTanjim/nui.nvim",

	-- Themes
	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin-nvim" },

	-- Completion (pinned to tag for prebuilt binaries)
	{ src = "https://github.com/Saghen/blink.cmp", version = "v1.8.0" },
}, { load = function() end })

-- Explicitly load essential plugins before lz.n
vim.cmd.packadd("lz.n")
vim.cmd.packadd("plenary.nvim")
vim.cmd.packadd("snacks.nvim")
vim.cmd.packadd("fzf-lua")
vim.cmd.packadd("nvim-treesitter")
vim.cmd.packadd("nvim-treesitter-textobjects")
vim.cmd.packadd("nvim-web-devicons")
vim.cmd.packadd("nui.nvim")

-- Configure treesitter (must happen after packadd)
---@diagnostic disable-next-line: missing-fields
require("nvim-treesitter.configs").setup({
	highlight = { enable = true },
	indent = { enable = true },
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "<C-space>",
			node_incremental = "<C-space>",
			scope_incremental = false,
			node_decremental = "<bs>",
		},
	},
	textobjects = {
		move = {
			enable = true,
			set_jumps = true,
			goto_next_start = {
				["]f"] = "@function.outer",
				["]c"] = "@class.outer",
				["]a"] = "@parameter.inner",
			},
			goto_next_end = {
				["]F"] = "@function.outer",
				["]C"] = "@class.outer",
				["]A"] = "@parameter.inner",
			},
			goto_previous_start = {
				["[f"] = "@function.outer",
				["[c"] = "@class.outer",
				["[a"] = "@parameter.inner",
			},
			goto_previous_end = {
				["[F"] = "@function.outer",
				["[C"] = "@class.outer",
				["[A"] = "@parameter.inner",
			},
		},
	},
})

vim.api.nvim_set_hl(0, "TreesitterContextBottom", { underline = false })

-- Textobjects move keymaps
local move = require("nvim-treesitter.textobjects.move")
local map = function(lhs, fn, query, desc)
	vim.keymap.set({ "n", "x", "o" }, lhs, function()
		fn(query)
	end, { desc = desc })
end
map("]f", move.goto_next_start, "@function.outer", "Next function")
map("[f", move.goto_previous_start, "@function.outer", "Prev function")
map("]c", move.goto_next_start, "@class.outer", "Next class")
map("[c", move.goto_previous_start, "@class.outer", "Prev class")
map("]a", move.goto_next_start, "@parameter.inner", "Next param")
map("[a", move.goto_previous_start, "@parameter.inner", "Prev param")

-- Load the rest via lz.n lazy loading
require("lz.n").load("plugins")

-- Set colorscheme
vim.cmd.colorscheme("catppuccin-mocha")
