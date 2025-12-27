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

	-- Editor
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

	-- LSP & Completion
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/folke/lazydev.nvim",
	"https://github.com/j-hui/fidget.nvim",
	"https://github.com/saecki/live-rename.nvim",

	-- Treesitter
	"https://github.com/nvim-treesitter/nvim-treesitter",
	"https://github.com/nvim-treesitter/nvim-treesitter-context",

	-- Mini.ai for textobjects (alternative to nvim-treesitter-textobjects)
	"https://github.com/echasnovski/mini.ai",

	-- Formatting & Linting
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/mfussenegger/nvim-lint",

	-- Language specific
	"https://github.com/mrcjkb/rustaceanvim",
	"https://github.com/saecki/crates.nvim",

	-- Markdown
	"https://github.com/MeanderingProgrammer/render-markdown.nvim",

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
vim.cmd.packadd("nvim-web-devicons")

-- Load the rest via lz.n lazy loading
require("lz.n").load("plugins")

-- Set colorscheme
vim.cmd.colorscheme("catppuccin-mocha")
