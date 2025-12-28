local map = vim.keymap.set

-- Entire buffer textobject (ig/ag)
map({ "o", "x" }, "ig", ":<C-u>normal! ggVG<CR>", { desc = "entire buffer", silent = true })
map({ "o", "x" }, "ag", ":<C-u>normal! ggVG<CR>", { desc = "entire buffer", silent = true })

-- Exit commands
map("n", "<C-c>", "<cmd>q<CR>", { desc = "Quit" })
map("n", "<C-x>", "<cmd>x<CR>", { desc = "Save and quit" })
map("n", "<leader>qq", "<cmd>qa<CR>", { desc = "Quit All" })
map("n", "<leader>Q", "<cmd>qa!<CR>", { desc = "Quit all (force)" })

-- Exit insert mode
map("i", "jj", "<Esc>", { desc = "Exit insert mode" })
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- Save file (LazyVim style)
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<CR><Esc>", { desc = "Save file" })

-- Clipboard (system clipboard integration) - saumavel custom
map("v", "y", '"+y', { silent = true, desc = "Copy to system clipboard" })
map("v", "Y", '"+Y', { silent = true, desc = "Copy line to system clipboard" })
map({ "n", "v" }, "p", '"+p', { silent = true, desc = "Paste from system clipboard" })
map({ "n", "v" }, "P", '"+P', { silent = true, desc = "Paste before from system clipboard" })

-- File operations
map("n", "<leader>fn", "<cmd>enew<CR>", { desc = "New File" })
map("n", "<leader>e", "<cmd>Oil<CR>", { desc = "Open Oil" })
map("n", "<leader>cw", [[:%s/^\s\+$//e<CR>]], { desc = "Clear whitespace-only lines" })
map({ "n", "v" }, "<leader>r", "<cmd>source $MYVIMRC<CR>", { desc = "Reload vim config" })

-- Saumavel: Create markdown link from selection and clipboard
map("v", "<leader>ml", "<Esc>`>a](<C-r>*)<C-o>`<[<Esc>", { desc = "Create markdown link" })

-- Copy path
map("n", "<leader>cy", function()
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	vim.notify("Copied: " .. path, vim.log.levels.INFO)
end, { desc = "Copy absolute path to clipboard" })

-- Better window navigation (will be overridden by tmux navigator)
map("n", "<C-h>", "<C-w>h", { desc = "Navigate left" })
map("n", "<C-j>", "<C-w>j", { desc = "Navigate down" })
map("n", "<C-k>", "<C-w>k", { desc = "Navigate up" })
map("n", "<C-l>", "<C-w>l", { desc = "Navigate right" })

-- Resize windows with arrows (LazyVim style)
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })

-- Better indenting
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- Clear search highlight
map("n", "<Esc>", "<cmd>noh<CR>", { desc = "Clear search highlight" })

-- Better search navigation (center on match)
map("n", "n", "nzzzv", { desc = "Next search result" })
map("n", "N", "Nzzzv", { desc = "Previous search result" })

-- Buffer navigation (LazyVim style) - [b, ]b are now default in 0.11+
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bb", "<cmd>e #<CR>", { desc = "Switch to other buffer" })
map("n", "<leader>`", "<cmd>e #<CR>", { desc = "Switch to other buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete Buffer" })
map("n", "<leader>bo", "<cmd>%bdelete|edit#|bdelete#<CR>", { desc = "Delete Other Buffers" })

-- Diagnostic navigation (Neovim 0.11+ uses vim.diagnostic.jump)
local diagnostic_jump = function(count, severity)
	severity = severity and vim.diagnostic.severity[severity] or nil
	return function()
		vim.diagnostic.jump({ count = count, severity = severity })
	end
end

map("n", "[d", diagnostic_jump(-1), { desc = "Previous diagnostic" })
map("n", "]d", diagnostic_jump(1), { desc = "Next diagnostic" })
map("n", "[e", diagnostic_jump(-1, "ERROR"), { desc = "Previous error" })
map("n", "]e", diagnostic_jump(1, "ERROR"), { desc = "Next error" })
map("n", "[w", diagnostic_jump(-1, "WARN"), { desc = "Previous warning" })
map("n", "]w", diagnostic_jump(1, "WARN"), { desc = "Next warning" })

-- Quickfix/Location list - [q, ]q are now default in 0.11+
map("n", "<leader>xq", "<cmd>copen<CR>", { desc = "Open quickfix list" })
map("n", "<leader>xl", "<cmd>lopen<CR>", { desc = "Open location list" })

-- LSP keymaps (basic - will be enhanced by plugins)
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gr", vim.lsp.buf.references, { desc = "Go to references" })
map("n", "gI", vim.lsp.buf.implementation, { desc = "Go to implementation" })
map("n", "gy", vim.lsp.buf.type_definition, { desc = "Go to type definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
map("n", "gK", vim.lsp.buf.signature_help, { desc = "Signature help" })
map("i", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature help" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
map("v", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename" })
map("n", "<leader>cl", vim.lsp.codelens.run, { desc = "Run codelens" })
map("n", "<leader>cL", vim.lsp.codelens.refresh, { desc = "Refresh codelens" })
map("n", "<leader>cf", function()
	vim.lsp.buf.format({ async = true })
end, { desc = "Format" })

-- Window splits (LazyVim style)
map("n", "<leader>-", "<C-w>s", { desc = "Split Below" })
map("n", "<leader>|", "<C-w>v", { desc = "Split Right" })
map("n", "<leader>wd", "<C-w>c", { desc = "Delete Window" })
map("n", "<leader>ww", "<C-w>p", { desc = "Other Window" })
map("n", "<leader>wm", function()
	vim.cmd("wincmd _")
	vim.cmd("wincmd |")
end, { desc = "Maximize Window" })

-- Toggle options (LazyVim style)
map("n", "<leader>uw", function()
	vim.wo.wrap = not vim.wo.wrap
	vim.notify("Wrap " .. (vim.wo.wrap and "enabled" or "disabled"))
end, { desc = "Toggle wrap" })

map("n", "<leader>ul", function()
	vim.wo.relativenumber = not vim.wo.relativenumber
	vim.notify("Relative numbers " .. (vim.wo.relativenumber and "enabled" or "disabled"))
end, { desc = "Toggle relative line numbers" })

map("n", "<leader>us", function()
	vim.wo.spell = not vim.wo.spell
	vim.notify("Spell " .. (vim.wo.spell and "enabled" or "disabled"))
end, { desc = "Toggle spelling" })

map("n", "<leader>ud", function()
	vim.diagnostic.enable(not vim.diagnostic.is_enabled())
	vim.notify("Diagnostics " .. (vim.diagnostic.is_enabled() and "enabled" or "disabled"))
end, { desc = "Toggle diagnostics" })

map("n", "<leader>uh", function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
	vim.notify("Inlay hints " .. (vim.lsp.inlay_hint.is_enabled() and "enabled" or "disabled"))
end, { desc = "Toggle Inlay Hints" })

map("n", "<leader>uf", function()
	vim.g.disable_autoformat = not vim.g.disable_autoformat
	vim.notify("Autoformat " .. (vim.g.disable_autoformat and "disabled" or "enabled"))
end, { desc = "Toggle Auto Format (Global)" })

map("n", "<leader>uF", function()
	vim.b.disable_autoformat = not vim.b.disable_autoformat
	vim.notify("Autoformat (buffer) " .. (vim.b.disable_autoformat and "disabled" or "enabled"))
end, { desc = "Toggle Auto Format (Buffer)" })

map("n", "<leader>ub", function()
	if vim.o.background == "dark" then
		vim.o.background = "light"
	else
		vim.o.background = "dark"
	end
end, { desc = "Toggle Background" })

map("n", "<leader>uL", function()
	vim.wo.number = not vim.wo.number
	vim.notify("Line numbers " .. (vim.wo.number and "enabled" or "disabled"))
end, { desc = "Toggle Line Numbers" })

map("n", "<leader>uC", function()
	local conceallevel = vim.o.conceallevel > 0 and vim.o.conceallevel or 3
	vim.o.conceallevel = vim.o.conceallevel == 0 and conceallevel or 0
	vim.notify("Conceallevel: " .. vim.o.conceallevel)
end, { desc = "Toggle Conceal" })

map("n", "<leader>uT", function()
	if vim.b.ts_highlight then
		vim.treesitter.stop()
	else
		vim.treesitter.start()
	end
	vim.notify("Treesitter " .. (vim.b.ts_highlight and "enabled" or "disabled"))
end, { desc = "Toggle Treesitter Highlight" })

-- Saumavel: Toggle completion using blink.cmp
map({ "n", "v" }, "<leader>uU", function()
	local blink_cmp = require("blink.cmp")
	if blink_cmp.is_enabled() then
		blink_cmp.hide()
		vim.notify("Disabled auto completion")
	else
		blink_cmp.show()
		vim.notify("Enabled auto completion")
	end
end, { desc = "Toggle suggestions" })

-- Saumavel: Enhanced URL handler for github: URLs and regular URLs
map("n", "gx", function()
	-- Cross-platform URL opener
	local open_url = function(url)
		local os_name = vim.loop.os_uname().sysname
		if os_name == "Darwin" then
			vim.fn.system({ "open", url })
		elseif os_name == "Linux" then
			vim.fn.system({ "xdg-open", url })
		elseif os_name == "Windows_NT" then
			vim.fn.system({ "cmd.exe", "/c", "start", url })
		else
			vim.notify("Unsupported OS for opening URLs", vim.log.levels.ERROR)
		end
	end

	-- Get the text under cursor
	local line = vim.fn.getline(".")
	local col = vim.fn.col(".")
	local start_col = col
	local end_col = col

	-- Find the start of the word
	while start_col > 0 and line:sub(start_col, start_col) ~= " " and line:sub(start_col, start_col) ~= "\t" do
		start_col = start_col - 1
	end

	-- Find the end of the word
	while end_col <= #line and line:sub(end_col, end_col) ~= " " and line:sub(end_col, end_col) ~= "\t" do
		end_col = end_col + 1
	end

	-- Extract the text
	local text = line:sub(start_col + 1, end_col - 1)

	-- Check if it matches our github: pattern (e.g., github:user/repo)
	local match = string.match(text, "github:([%w%-_]+/[%w%-_]+)")
	if match then
		local url = "https://github.com/" .. match .. "?tab=readme-ov-file"
		open_url(url)
		return
	end

	-- Use Neovim's built-in URL detection
	local url = vim.fn.expand("<cfile>")

	-- Check if it's a URL we can handle
	if url:match("^https?://") or url:match("^www%.") then
		open_url(url)
		return
	end

	-- Otherwise, fall back to Neovim's built-in behavior
	vim.ui.open(url)
end, { noremap = true, silent = true, desc = "Open URL" })

-- Diagnostic float
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })

-- Keywordprg
map("n", "<leader>K", "<cmd>norm! K<CR>", { desc = "Keywordprg" })

-- Terminal (LazyVim style)
map("n", "<C-/>", function()
	Snacks.terminal()
end, { desc = "Terminal (Root Dir)" })
map("n", "<C-_>", function()
	Snacks.terminal()
end, { desc = "which_key_ignore" })
map("t", "<C-/>", "<cmd>close<CR>", { desc = "Hide Terminal" })
map("t", "<C-_>", "<cmd>close<CR>", { desc = "which_key_ignore" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Enter Normal Mode" })
map("t", "<C-h>", "<cmd>wincmd h<CR>", { desc = "Go to Left Window" })
map("t", "<C-j>", "<cmd>wincmd j<CR>", { desc = "Go to Lower Window" })
map("t", "<C-k>", "<cmd>wincmd k<CR>", { desc = "Go to Upper Window" })
map("t", "<C-l>", "<cmd>wincmd l<CR>", { desc = "Go to Right Window" })

-- Lazygit
map("n", "<leader>gg", function()
	Snacks.lazygit()
end, { desc = "Lazygit (Root Dir)" })
map("n", "<leader>gL", function()
	Snacks.lazygit.log()
end, { desc = "Lazygit Log (cwd)" })
map("n", "<leader>gf", function()
	Snacks.lazygit.log_file()
end, { desc = "Lazygit Current File History" })
map("n", "<leader>gl", function()
	Snacks.lazygit.log()
end, { desc = "Git Log" })
map("n", "<leader>gB", function()
	Snacks.gitbrowse()
end, { desc = "Git Browse" })
map({ "n", "x" }, "<leader>gY", function()
	Snacks.gitbrowse({
		open = function(url)
			vim.fn.setreg("+", url)
		end,
		notify = false,
	})
end, { desc = "Git Browse (copy)" })

-- Blame line
map("n", "<leader>gb", function()
	Snacks.git.blame_line()
end, { desc = "Git Blame Line" })

-- Better j/k for wrapped lines
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "Down" })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "Up" })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "Down" })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "Up" })

-- Commenting (LazyVim style - using native Neovim 0.10+)
map("n", "gco", "o<Esc>Vcx<Esc><cmd>normal gcc<CR>fxa<BS>", { desc = "Add Comment Below" })
map("n", "gcO", "O<Esc>Vcx<Esc><cmd>normal gcc<CR>fxa<BS>", { desc = "Add Comment Above" })

-- Search and replace (LazyVim style)
map({ "n", "x" }, "<leader>sr", function()
	local cword = vim.fn.expand("<cword>")
	vim.ui.input({ prompt = "Search: ", default = cword }, function(search)
		if not search or search == "" then
			return
		end
		vim.ui.input({ prompt = "Replace: " }, function(replace)
			if replace == nil then
				return
			end
			local cmd = ":%s/" .. vim.fn.escape(search, "/\\") .. "/" .. vim.fn.escape(replace, "/\\") .. "/gc"
			vim.cmd(cmd)
		end)
	end)
end, { desc = "Search and Replace" })

-- Inspect (LazyVim style)
map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
map("n", "<leader>uI", function()
	vim.treesitter.inspect_tree()
end, { desc = "Inspect Tree" })

-- Plugin manager (using vim.pack instead of lazy.nvim)
map("n", "<leader>l", "<cmd>PackUpdate<CR>", { desc = "Update Plugins" })

-- Undo tree
map("n", "<leader>uu", "<cmd>UndotreeToggle<CR>", { desc = "Toggle Undotree" })

-- Notifications
map("n", "<leader>un", function()
	Snacks.notifier.hide()
end, { desc = "Dismiss All Notifications" })
map("n", "<leader>sn", function()
	Snacks.notifier.show_history()
end, { desc = "Notification History" })

-- Buffer (also with Snacks)
map("n", "<leader>bD", function()
	Snacks.bufdelete()
end, { desc = "Delete Buffer" })

-- Scratch/Notes
map("n", "<leader>.", function()
	Snacks.scratch()
end, { desc = "Toggle Scratch Buffer" })
map("n", "<leader>S", function()
	Snacks.scratch.select()
end, { desc = "Select Scratch Buffer" })

-- Zen mode (if available)
map("n", "<leader>z", function()
	Snacks.zen()
end, { desc = "Toggle Zen Mode" })
map("n", "<leader>Z", function()
	Snacks.zen.zoom()
end, { desc = "Toggle Zoom" })
