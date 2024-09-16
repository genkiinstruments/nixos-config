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

vim.api.nvim_buf_set_var(0, "cmp", false)

keymap({ "n", "v" }, "<leader>uU", function()
    if vim.fn.exists("b:cmp") == 0 or vim.api.nvim_buf_get_var(0, "cmp") then
        vim.api.nvim_buf_set_var(0, "cmp", false)
        require("cmp").setup.buffer({ enabled = false })
        vim.notify("Disabled auto cmpletion")
    else
        vim.api.nvim_buf_set_var(0, "cmp", true)
        require("cmp").setup.buffer({ enabled = true })
        vim.notify("Enabled auto cmpletion")
    end
end, { desc = "Toggle suggestions" })

-- Don't use nvim toggle term stuff.. use floatx term instead!
vim.keymap.del("n", "<leader>ft")
vim.keymap.del("n", "<leader>fT")
vim.keymap.del("n", "<C-_>")
vim.keymap.del("n", "<C-/>")
