local keymap = vim.keymap.set

keymap("n", "<C-c>", "<cmd>q<cr>", { noremap = true })
keymap("n", "<C-x>", "<cmd>x<cr>", { noremap = true })

-- Search and replace
keymap("n", "<leader>r", ":%s/<<C-r><C-w>>//g<Left><Left>")

-- Unmap keymaps that move lines
for _, val in pairs({ "<A-j>", "<A-k>" }) do
    vim.keymap.del({ "n", "i", "v" }, val)
end

-- Don't want navigation in terminal-mode
for _, val in pairs({ "<C-h>", "<C-j>", "<C-k>", "<C-l>" }) do
    vim.keymap.del("t", val)
end

keymap("i", "jj", "<Esc>", { desc = "Exit insert mode" })
