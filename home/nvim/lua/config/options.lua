-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Filetype detection
vim.cmd("filetype plugin indent on")

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Cursor
vim.opt.cursorline = true

-- Undo
vim.opt.undofile = true
vim.opt.swapfile = false

-- Indentation
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

-- UI
vim.opt.signcolumn = "yes"
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.wrap = false
vim.opt.termguicolors = true
vim.opt.showtabline = 0
vim.opt.cmdheight = 0
vim.opt.laststatus = 3

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Splits
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Clipboard
vim.opt.clipboard = "unnamedplus"

-- Mouse
vim.opt.mouse = "a"

-- Folding (treesitter-based)
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext = ""
vim.opt.foldlevel = 99

-- Grep
vim.opt.grepprg = "rg --vimgrep --hidden -g '!.git/*'"

-- Completion (Neovim 0.11+ features)
vim.opt.completeopt = "menu,menuone,noselect,fuzzy,preview"

-- Floating window border (Neovim 0.11+)
vim.opt.winborder = "rounded"

-- Diagnostics
vim.diagnostic.config({
	virtual_text = {
		source = true,
		prefix = "● ",
	},
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.INFO] = " ",
			[vim.diagnostic.severity.HINT] = " ",
		},
	},
	float = { source = true },
	jump = {
		on_jump = function()
			vim.diagnostic.open_float()
		end,
	},
	severity_sort = true,
})
