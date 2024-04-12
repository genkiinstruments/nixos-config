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

return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
		-- stylua: ignore
		keys = {
			{ '<leader>a', function() require('harpoon'):list():add() end, desc = 'Add harpoon location' },
			{ '<leader>H', function() require('harpoon'):list():add() end, desc = 'Add harpoon location' },
			{ '<C-n>', function() require('harpoon'):list():next() end, desc = 'Next harpoon location' },
			{ '<C-p>', function() require('harpoon'):list():prev() end, desc = 'Previous harpoon location' },
			{ '<leader>mr', function() require('harpoon'):list():remove() end, desc = 'Remove harpoon location' },
			{ '<leader>1', function() require('harpoon'):list():select(1) end, desc = 'Harpoon select 1' },
			{ '<leader>2', function() require('harpoon'):list():select(2) end, desc = 'Harpoon select 2' },
			{ '<leader>3', function() require('harpoon'):list():select(3) end, desc = 'Harpoon select 3' },
			{ '<leader>4', function() require('harpoon'):list():select(4) end, desc = 'Harpoon select 4' },
			{ '<leader>5', function() require('harpoon'):list():select(5) end, desc = 'Harpoon select 5' },
      { "<C-e>", function() toggle_telescope(require("harpoon"):list()) end, desc = "Open harpoon window"},
      { "<leader>h", function() toggle_telescope(require("harpoon"):list()) end, desc = "Open harpoon window"}
  },
}
