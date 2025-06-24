local vault_config = require("config.vault")

return {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = false,
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    opts = {
        workspaces = {
            {
                name = "personal",
                path = vault_config.path,
            },
        },
        notes_subdir = vault_config.notes_subdir,
        daily_notes = vault_config.daily_notes,

        completion = {
            nvim_cmp = false,
            min_chars = 2,
            default = true,
        },

        templates = {
            subdir = "templates", -- Changed 'folder' to 'subdir'
            date_format = "%Y-%m-%d",
            time_format = "%H:%M",
            default = true,
        },

        picker = {
            name = "telescope.nvim",
            note_mappings = {},
            tag_mappings = {},
            default = true,
        },

        ui = {
            enable = true,
            update_debounce = 200,
            checkboxes = {
                [" "] = { char = "󰄱", hl_group = "ObsidianTodo", default = true },
                ["x"] = { char = "", hl_group = "ObsidianDone", default = true },
                [">"] = { char = "", hl_group = "ObsidianRightArrow", default = true },
                ["~"] = { char = "󰰱", hl_group = "ObsidianTilde", default = true },
            },
            bullets = { char = "•", hl_group = "ObsidianBullet" },
            external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
            reference_text = { hl_group = "ObsidianRefText" },
            highlight_text = { hl_group = "ObsidianHighlightText" },
            tags = { hl_group = "ObsidianTag" },
            hl_groups = {
                ObsidianTodo = { bold = true, fg = "#f78c6c" },
                ObsidianDone = { bold = true, fg = "#89ddff" },
                ObsidianRightArrow = { bold = true, fg = "#f78c6c" },
                ObsidianTilde = { bold = true, fg = "#ff5370" },
                ObsidianBullet = { bold = true, fg = "#89ddff" },
                ObsidianRefText = { underline = true, fg = "#c792ea" },
                ObsidianExtLinkIcon = { fg = "#c792ea" },
                ObsidianTag = { italic = true, fg = "#89ddff" },
                ObsidianHighlightText = { bg = "#75662e" },
            },
        },

        follow_url_func = function(url)
            vim.fn.jobstart({ "open", url })
        end,

        sort_by = "modified",
        sort_reversed = true,
        open_notes_in = "current",

        attachments = {
            img_folder = "assets/imgs",
            img_text_func = function(img_path)
                local link_path
                if img_path:match("^[~/]") then
                    link_path = img_path
                else
                    link_path = require("plenary.path"):new(img_path):filename()
                end
                return string.format("![[%s]]", link_path)
            end,
        },
    },
}
