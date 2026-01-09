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
	"https://github.com/folke/noice.nvim",
	"https://github.com/MunifTanjim/nui.nvim",

	-- Editor
	"https://github.com/echasnovski/mini.ai",
	"https://github.com/stevearc/oil.nvim",
	"https://github.com/folke/flash.nvim",
	"https://github.com/kylechui/nvim-surround",
	"https://github.com/windwp/nvim-autopairs",
	"https://github.com/christoomey/vim-tmux-navigator",
	"https://github.com/mbbill/undotree",
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/folke/todo-comments.nvim",

	-- Fuzzy finding (fzf-lua like LazyVim)
	"https://github.com/ibhagwan/fzf-lua",
	"https://github.com/elanmed/fzf-lua-frecency.nvim",

	-- LSP & Completion
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/folke/lazydev.nvim",
	"https://github.com/j-hui/fidget.nvim",
	"https://github.com/saecki/live-rename.nvim",

	-- Treesitter
	"https://github.com/nvim-treesitter/nvim-treesitter",
	"https://github.com/nvim-treesitter/nvim-treesitter-context",
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" },
	"https://github.com/windwp/nvim-ts-autotag",

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
vim.cmd.packadd("fzf-lua-frecency.nvim")
vim.cmd.packadd("nvim-treesitter")
vim.cmd.packadd("nvim-web-devicons")
vim.cmd.packadd("nui.nvim")
vim.cmd.packadd("noice.nvim")
vim.cmd.packadd("friendly-snippets") -- Must load before LuaSnip's lazy_load()

-- Configure treesitter using the new API (nvim-treesitter.configs was removed)
require("nvim-treesitter").setup({
	highlight = { enable = true },
	indent = { enable = true },
})

-- Incremental selection keymaps (replaces incremental_selection config)
vim.keymap.set("n", "<C-space>", function()
	require("nvim-treesitter.incremental_selection").init_selection()
end, { desc = "Init selection" })
vim.keymap.set("x", "<C-space>", function()
	require("nvim-treesitter.incremental_selection").node_incremental()
end, { desc = "Increment selection" })
vim.keymap.set("x", "<bs>", function()
	require("nvim-treesitter.incremental_selection").node_decremental()
end, { desc = "Decrement selection" })

vim.api.nvim_set_hl(0, "TreesitterContextBottom", { underline = false })

-- Load textobjects after treesitter is configured
vim.cmd.packadd("nvim-treesitter-textobjects")
require("nvim-treesitter-textobjects").setup({
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
})

-- Load the rest via lz.n lazy loading
require("lz.n").load("plugins")

-- Set colorscheme
vim.cmd.colorscheme("catppuccin-mocha")
