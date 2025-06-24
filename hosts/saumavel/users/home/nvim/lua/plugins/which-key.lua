return {
    "folke/which-key.nvim",
    optional = true,
    opts = function(_, opts)
        -- Make sure the spec table exists
        if not opts.spec then
            opts.spec = {}
        end

        -- Add the Obsidian group using the new format
        table.insert(opts.spec, { "<leader>o", group = "+Obsidian" })

        return opts
    end,
}
