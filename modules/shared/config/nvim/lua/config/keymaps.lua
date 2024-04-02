-- stylua: ignore start
vim.keymap.set({ mode = "n", expr = false, noremap = true }, "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set({ mode = "n", expr = false, noremap = true }, "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set( { mode = "v", expr = false, noremap = true }, "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move block of lines down" })
vim.keymap.set( { mode = "v", expr = false, noremap = true }, "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move block of lines up" })
vim.keymap.set( { mode = "i", expr = false, noremap = true }, "<A-j>", "<Esc>:m .+1<CR>==gi", { desc = "Move line down in insert mode" })
vim.keymap.set( { mode = "i", expr = false, noremap = true }, "<A-k>", "<Esc>:m .-2<CR>==gi", { desc = "Move line up in insert mode" })

-- Launch panel if nothing is typed after <leader>z
vim.keymap.set("n", "<leader>z", "<cmd>Telekasten panel<CR>")

-- Most used functions
vim.keymap.set("n", "<leader>zf", "<cmd>Telekasten find_notes<CR>")
vim.keymap.set("n", "<leader>zg", "<cmd>Telekasten search_notes<CR>")
vim.keymap.set("n", "<leader>zd", "<cmd>Telekasten goto_today<CR>")
vim.keymap.set("n", "<leader>zz", "<cmd>Telekasten follow_link<CR>")
vim.keymap.set("n", "<leader>zn", "<cmd>Telekasten new_note<CR>")
vim.keymap.set("n", "<leader>zc", "<cmd>Telekasten show_calendar<CR>")
vim.keymap.set("n", "<leader>zb", "<cmd>Telekasten show_backlinks<CR>")
vim.keymap.set("n", "<leader>zI", "<cmd>Telekasten insert_img_link<CR>")
vim.keymap.set("n", "<leader>zt", "<cmd>Telekasten toggle_todo<CR>")

-- Call insert link automatically when we start typing a link
vim.keymap.set("i", "[[", "<cmd>Telekasten insert_link<CR>")

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- stylua: ignore end
