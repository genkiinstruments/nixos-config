-- stylua: ignore start
vim.keymap.set({ mode = "n", expr = false, noremap = true }, "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set({ mode = "n", expr = false, noremap = true }, "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set( { mode = "v", expr = false, noremap = true }, "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move block of lines down" })
vim.keymap.set( { mode = "v", expr = false, noremap = true }, "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move block of lines up" })
vim.keymap.set( { mode = "i", expr = false, noremap = true }, "<A-j>", "<Esc>:m .+1<CR>==gi", { desc = "Move line down in insert mode" })
vim.keymap.set( { mode = "i", expr = false, noremap = true }, "<A-k>", "<Esc>:m .-2<CR>==gi", { desc = "Move line up in insert mode" })

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- stylua: ignore end
