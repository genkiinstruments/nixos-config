local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Enable treesitter highlighting for all supported filetypes
autocmd("FileType", {
	group = augroup("treesitter_highlight", { clear = true }),
	callback = function(args)
		pcall(vim.treesitter.start, args.buf)
	end,
})

-- vim.pack user commands (Neovim 0.12+)
vim.api.nvim_create_user_command("PackUpdate", function()
	vim.pack.update()
end, { desc = "Update all plugins" })

vim.api.nvim_create_user_command("PackClean", function()
	vim.pack.clean()
end, { desc = "Clean unused plugins" })

-- Highlight on yank
autocmd("TextYankPost", {
	group = augroup("highlight_yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank({ timeout = 200 })
	end,
})

-- Auto save on focus lost (only normal buffers)
-- autocmd("FocusLost", {
-- 	group = augroup("auto_save", { clear = true }),
-- 	callback = function()
-- 		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
-- 			if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" and vim.bo[buf].modified then
-- 				vim.api.nvim_buf_call(buf, function()
-- 					vim.cmd("silent! write")
-- 				end)
-- 			end
-- 		end
-- 	end,
-- })

-- Resize splits on window resize
autocmd("VimResized", {
	group = augroup("resize_splits", { clear = true }),
	callback = function()
		vim.cmd("tabdo wincmd =")
	end,
})

-- Close some filetypes with q
autocmd("FileType", {
	group = augroup("close_with_q", { clear = true }),
	pattern = {
		"help",
		"lspinfo",
		"man",
		"notify",
		"qf",
		"checkhealth",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true })
	end,
})

-- Check if we need to reload the file when it changed
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = augroup("checktime", { clear = true }),
	command = "checktime",
})

-- Go to last location when opening a buffer
autocmd("BufReadPost", {
	group = augroup("last_loc", { clear = true }),
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Disable syntax for large files
autocmd("BufReadPre", {
	group = augroup("bigfile", { clear = true }),
	callback = function(args)
		local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(args.buf))
		if ok and stats and stats.size > 1024 * 1024 then
			vim.b[args.buf].large_file = true
			vim.cmd("syntax off")
		end
	end,
})

-- Disable fish syntax (causes issues)
autocmd({ "BufRead", "BufNewFile" }, {
	group = augroup("fish_syntax", { clear = true }),
	pattern = "*.fish",
	command = "syntax off",
})
