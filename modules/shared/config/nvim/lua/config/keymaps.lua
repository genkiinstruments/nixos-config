local keymap = vim.keymap.set

keymap("n", "<C-c>", "<cmd>q<cr>", { noremap = true })
keymap("n", "<C-x>", "<cmd>x<cr>", { noremap = true })

-- floating terminal
local lazyterm = function()
    local Util = require("lazyvim.util")
    Util.terminal(nil, { cwd = Util.root() })
end

keymap("n", "<c-\\>", lazyterm, { desc = "Terminal (root dir)" })
keymap("t", "<C-\\>", "<cmd>close<cr>", { desc = "Hide Terminal" })

keymap("n", "<C-/>", lazyterm, { desc = "Terminal (root dir)" })
keymap("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })

-- Unmap keymaps that move lines
vim.keymap.del({ "n", "i", "v", "t" }, "<A-j>")
vim.keymap.del({ "n", "i", "v", "t" }, "<A-k>")
