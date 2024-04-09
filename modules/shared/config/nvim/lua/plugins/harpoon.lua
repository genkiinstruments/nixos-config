return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    opts = {
        menu = {
            width = vim.api.nvim_win_get_width(0) - 4,
        },
    },
    keys = function()
        local keys = {
            {
                "<leader>H",
                function()
                    require("harpoon"):list():add()
                end,
                desc = "Harpoon File",
            },
            {
                "<leader>h",
                function()
                    local harpoon = require("harpoon")
                    harpoon.ui:toggle_quick_menu(harpoon:list())
                end,
                desc = "Harpoon Quick Menu",
            },
            {
                "<C-S-P>",
                function()
                    local harpoon = require("harpoon")
                    harpoon:list():prev()
                end,
                desc = "Toggle previous buffer stored within Harpoon list",
            },
            {
                "<C-S-N>",
                function()
                    local harpoon = require("harpoon")
                    harpoon:list():next()
                end,
                desc = "Toggle next buffer stored within Harpoon list",
            },
        }

        for i = 1, 5 do
            table.insert(keys, {
                "<leader>" .. i,
                function()
                    require("harpoon"):list():select(i)
                end,
                desc = "Harpoon to File " .. i,
            })
        end
        return keys
    end,
}
