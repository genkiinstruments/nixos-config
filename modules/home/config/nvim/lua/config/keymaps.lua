local keymap = vim.keymap.set

keymap("n", "<C-c>", "<cmd>q<cr>", { noremap = true })
keymap("n", "<C-x>", "<cmd>x<cr>", { noremap = true })

-- Unmap keymaps that move lines
for _, val in pairs({ "<A-j>", "<A-k>" }) do
    vim.keymap.del({ "n", "i", "v" }, val)
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

keymap("v", "<leader>ml", "<Esc>`>a](<C-r>*)<C-o>`<[<Esc>")

keymap({ "n", "v" }, "<leader>e", "<cmd>LazyExtra<CR>", { desc = "Open Lazy Extra menu" })

keymap({ "n", "v" }, "<leader>r", "<cmd>source $MYVIMRC<CR>", { desc = "Reload vim config" })
