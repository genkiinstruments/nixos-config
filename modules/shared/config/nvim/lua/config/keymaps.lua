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

keymap("n", "<C-þ>", lazyterm, { desc = "Terminal (root dir)" })
keymap("t", "<C-þ>", "<cmd>close<cr>", { desc = "Hide Terminal" })

-- Unmap keymaps that move lines
vim.keymap.del({ "n", "i", "v" }, "<A-j>")
vim.keymap.del({ "n", "i", "v" }, "<A-k>")

-- Don't want navigation in terminal-mode
for _, val in pairs({ "<C-h>", "<C-j>", "<C-k>", "<C-l>" }) do
    vim.keymap.del("t", val)
end

local function toggle_telescope(harpoon_files)
    local file_paths = {}
    for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
    end
    local conf = require("telescope.config").values
    require("telescope.pickers")
        .new({}, {
            prompt_title = "Harpoon",
            finder = require("telescope.finders").new_table({
                results = file_paths,
            }),
            previewer = conf.file_previewer({}),
            sorter = conf.generic_sorter({}),
        })
        :find()
end

-- stylua: ignore
vim.keymap.set("n", "<C-e>", function() toggle_telescope(require("harpoon"):list()) end, { desc = "Open harpoon window" })
