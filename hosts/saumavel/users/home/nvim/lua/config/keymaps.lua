local keymap = vim.keymap.set

-- Unmap keymaps that move lines
for _, val in pairs({ "<A-j>", "<A-k>" }) do
    vim.keymap.del({ "n", "i", "v" }, val)
end

vim.api.nvim_buf_set_var(0, "cmp", false)

-- insert mode
keymap("i", "jj", "<Esc>", { desc = "Exit insert mode" })
keymap("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- visual mode
keymap("v", "<leader>ml", "<Esc>`>a](<C-r>*)<C-o>`<[<Esc>")

keymap({ "n", "v" }, "<leader>h", "<cmd>LazyExtra<CR>", { desc = "Open Lazy Extra menu" })
keymap({ "n", "v" }, "<leader>e", "<cmd>Oil<CR>", { desc = "Open Oil" })

keymap({ "n", "v" }, "<leader>r", "<cmd>source $MYVIMRC<CR>", { desc = "Reload vim config" })

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

-- normal mode
keymap("n", "<C-c>", "<cmd>q<cr>", { noremap = true })
keymap("n", "<C-x>", "<cmd>x<cr>", { noremap = true })

keymap("n", "<leader>cw", ":%s/^\\s\\+$//e<CR>", { desc = "Clear whitespace-only lines" })
