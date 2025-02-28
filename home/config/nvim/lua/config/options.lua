-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- Disable swap files
vim.opt.swapfile = false

--  https://old.reddit.com/r/neovim/comments/1ajpdrx/lazyvim_weird_live_grep_root_dir_functionality_in/
-- Type :LazyRoot in the directory you're in and that will show you the root_dir that will be used for the root_dir search commands. The reason you're experiencing this behavior is because your subdirectories contain some kind of root_dir pattern for the LSP server attached to the buffer.
vim.g.root_spec = { "cwd" }

vim.opt.spell = false

-- Disable syntax highlighting for .fish files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = "*.fish",
    callback = function()
        vim.cmd("syntax off")
    end,
})

-- Don't show tabs
vim.cmd([[ set showtabline=0 ]])

-- Disable animations
vim.g.snacks_animate = false
