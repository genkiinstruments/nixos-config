local keymap = vim.keymap.set
local vault_config = require("config.vault")

keymap("n", "<C-c>", "<cmd>q<cr>", { noremap = true })
keymap("n", "<C-x>", "<cmd>x<cr>", { noremap = true })

-- Unmap keymaps that move lines
for _, val in pairs({ "<A-j>", "<A-k>" }) do
    vim.keymap.del({ "n", "i", "v" }, val)
end

keymap("i", "jj", "<Esc>", { desc = "Exit insert mode" })
keymap("i", "jk", "<Esc>", { desc = "Exit insert mode" })

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

keymap({ "n", "v" }, "<leader>h", "<cmd>LazyExtra<CR>", { desc = "Open Lazy Extra menu" })
keymap({ "n", "v" }, "<leader>e", "<cmd>Oil<CR>", { desc = "Open Oil" })

keymap({ "n", "v" }, "<leader>r", "<cmd>source $MYVIMRC<CR>", { desc = "Reload vim config" })

keymap("n", "<leader>cw", ":%s/^\\s\\+$//e<CR>", { desc = "Clear whitespace-only lines" })

-- Obsidian keymappings
keymap("n", "<leader>oo", "<cmd>ObsidianOpen<CR>", { desc = "Open in Obsidian" })
keymap("n", "<leader>on", "<cmd>ObsidianNew<CR>", { desc = "New note" })
keymap("n", "<leader>oq", "<cmd>ObsidianQuickSwitch<CR>", { desc = "Quick switch" })
keymap("n", "<leader>os", "<cmd>ObsidianSearch<CR>", { desc = "Search" })
keymap("n", "<leader>of", "<cmd>ObsidianFollowLink<CR>", { desc = "Follow link" })
keymap("n", "<leader>ob", "<cmd>ObsidianBacklinks<CR>", { desc = "Backlinks" })
keymap("n", "<leader>ot", "<cmd>ObsidianToday<CR>", { desc = "Today's note" })
keymap("n", "<leader>oi", "<cmd>ObsidianTemplate<CR>", { desc = "Insert template" })
keymap("n", "<leader>ol", "<cmd>ObsidianLink<CR>", { desc = "Link to note" })
keymap("n", "<leader>oL", "<cmd>ObsidianLinkNew<CR>", { desc = "New note with link" })
keymap("n", "<leader>op", "<cmd>ObsidianPasteImg<CR>", { desc = "Paste image" })
keymap("n", "<leader>og", "<cmd>ObsidianTags<CR>", { desc = "Tags" })
keymap("n", "<leader>or", "<cmd>ObsidianRename<CR>", { desc = "Rename note" })

-- For toggle checkbox, we need to use the function directly
keymap("n", "<leader>oc", function()
    require("obsidian").util.toggle_checkbox()
end, { desc = "Toggle checkbox" })

-- Open Oil in Obsidian vault directory
keymap("n", "<leader>oe", function()
    local expanded_path = vim.fn.expand(vault_config.path)

    if vim.fn.isdirectory(expanded_path) == 1 then
        vim.cmd("Oil " .. expanded_path)
    else
        vim.notify("Obsidian vault directory not found: " .. expanded_path, vim.log.levels.WARN)
    end
end, { desc = "Open Oil in Obsidian vault" })
