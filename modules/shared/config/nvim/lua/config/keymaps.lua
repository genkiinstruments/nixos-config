local keymap = vim.keymap.set

keymap("n", "<C-c>", "<cmd>q<cr>", { noremap = true })
keymap("n", "<C-x>", "<cmd>x<cr>", { noremap = true })

-- Unmap keymaps that move lines
for _, val in pairs({ "<A-j>", "<A-k>" }) do
    vim.keymap.del({ "n", "i", "v" }, val)
end

-- Don't want navigation in terminal-mode
for _, val in pairs({ "<C-h>", "<C-j>", "<C-k>", "<C-l>" }) do
    vim.keymap.del("t", val)
end

-- Disable lazyterm
vim.keymap.del("n", "<leader>ft")
vim.keymap.del("n", "<leader>fT")
vim.keymap.del("n", "<c-/>")
vim.keymap.del("n", "<c-_>")
