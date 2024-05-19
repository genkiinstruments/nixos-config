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

-- Primagen inspired keymaps for trouble/quickfix
keymap("n", "<c-k>", vim.cmd.cprev, { desc = "Previous Quickfix" })
keymap("n", "<c-j>", vim.cmd.cnext, { desc = "Next Quickfix" })

keymap("i", "jj", "<Esc>", { desc = "Exit insert mode" })
