-- ============================================================================
-- Keymaps Configuration
-- ============================================================================
-- Custom keybindings for normal, insert, visual, and other modes

local keymap = vim.keymap.set

-- ============================================================================
-- General
-- ============================================================================

-- Reload vim configuration
keymap({ "n", "v" }, "<leader>r", "<cmd>source $MYVIMRC<CR>", { desc = "Reload vim config" })

-- Plugin menus
keymap({ "n", "v" }, "<leader>h", "<cmd>LazyExtra<CR>", { desc = "Open Lazy Extra menu" })
keymap({ "n", "v" }, "<leader>e", "<cmd>Oil<CR>", { desc = "Open Oil" })

-- ============================================================================
-- Normal Mode
-- ============================================================================

-- Quick quit and save+quit
keymap("n", "<C-c>", "<cmd>q<cr>", { noremap = true })
keymap("n", "<C-x>", "<cmd>x<cr>", { noremap = true })

-- Clear whitespace-only lines
keymap("n", "<leader>cw", ":%s/^\\s\\+$//e<CR>", { desc = "Clear whitespace-only lines" })

-- ============================================================================
-- Insert Mode
-- ============================================================================

-- Quick escape to normal mode
keymap("i", "jj", "<Esc>", { desc = "Exit insert mode" })
keymap("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- ============================================================================
-- Visual Mode
-- ============================================================================

-- Create markdown link from selection and clipboard
keymap("v", "<leader>ml", "<Esc>`>a](<C-r>*)<C-o>`<[<Esc>", { desc = "Create markdown link" })

-- ============================================================================
-- Clipboard Operations
-- ============================================================================

-- Visual mode clipboard mappings
keymap("v", "y", '"+y', { silent = true, desc = "Copy to system clipboard" })
keymap("v", "Y", '"+Y', { silent = true, desc = "Copy line to system clipboard" })
keymap("v", "p", '"+p', { silent = true, desc = "Paste from system clipboard" })
keymap("v", "P", '"+P', { silent = true, desc = "Paste before from system clipboard" })

-- Normal mode clipboard mappings
keymap("n", "p", '"+p', { silent = true, desc = "Paste from system clipboard" })
keymap("n", "P", '"+P', { silent = true, desc = "Paste before from system clipboard" })

-- ============================================================================
-- Disabled Keymaps
-- ============================================================================

-- Unmap keymaps that move lines (Alt+j/k)
for _, val in pairs({ "<A-j>", "<A-k>" }) do
    vim.keymap.del({ "n", "i", "v" }, val)
end

-- ============================================================================
-- Completion Settings
-- ============================================================================

-- Disable completion for current buffer by default
vim.api.nvim_buf_set_var(0, "cmp", false)

-- Toggle completion using blink.cmp
keymap({ "n", "v" }, "<leader>uU", function()
    local blink_cmp = require("blink.cmp")
    if blink_cmp.is_enabled() then
        blink_cmp.hide()
        vim.notify("Disabled auto completion")
    else
        blink_cmp.show()
        vim.notify("Enabled auto completion")
    end
end, { desc = "Toggle suggestions" })

-- ============================================================================
-- URL Handling
-- ============================================================================

-- Enhanced URL handler for both github: URLs and regular URLs
keymap("n", "gx", function()
    -- Cross-platform URL opener
    local open_url = function(url)
        local os_name = vim.loop.os_uname().sysname
        if os_name == "Darwin" then
            vim.fn.system({ "open", url })
        elseif os_name == "Linux" then
            vim.fn.system({ "xdg-open", url })
        elseif os_name == "Windows_NT" then
            vim.fn.system({ "cmd.exe", "/c", "start", url })
        else
            vim.notify("Unsupported OS for opening URLs", vim.log.levels.ERROR)
        end
    end

    -- Get the text under cursor
    local line = vim.fn.getline(".")
    local col = vim.fn.col(".")
    local start_col = col
    local end_col = col

    -- Find the start of the word
    while start_col > 0 and line:sub(start_col, start_col) ~= " " and line:sub(start_col, start_col) ~= "\t" do
        start_col = start_col - 1
    end

    -- Find the end of the word
    while end_col <= #line and line:sub(end_col, end_col) ~= " " and line:sub(end_col, end_col) ~= "\t" do
        end_col = end_col + 1
    end

    -- Extract the text
    local text = line:sub(start_col + 1, end_col - 1)

    -- Check if it matches our github: pattern (e.g., github:user/repo)
    local match = string.match(text, "github:([%w%-_]+/[%w%-_]+)")
    if match then
        local url = "https://github.com/" .. match .. "?tab=readme-ov-file"
        open_url(url)
        return
    end

    -- Use Neovim's built-in URL detection
    local url = vim.fn.expand("<cfile>")

    -- Check if it's a URL we can handle
    if url:match("^https?://") or url:match("^www%.") then
        open_url(url)
        return
    end

    -- Otherwise, fall back to Neovim's built-in behavior
    vim.cmd("call netrw#BrowseX(netrw#GX(),netrw#CheckIfRemote())")
end, { noremap = true, silent = true, desc = "Open URL" })
