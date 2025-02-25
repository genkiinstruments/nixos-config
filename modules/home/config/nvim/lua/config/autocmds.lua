-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Save on focus lost
vim.api.nvim_create_autocmd("FocusLost", {
    command = "silent! wa",
    pattern = "*",
})
