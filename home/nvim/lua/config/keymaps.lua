local keymap = vim.keymap.set

keymap("n", "<C-c>", "<cmd>q<cr>", { noremap = true })
keymap("n", "<C-x>", "<cmd>x<cr>", { noremap = true })

-- Unmap keymaps that move lines
for _, val in pairs({ "<A-j>", "<A-k>" }) do
    vim.keymap.del({ "n", "i", "v" }, val)
end

keymap("i", "jj", "<Esc>", { desc = "Exit insert mode" })

-- GitHub link handler
keymap("n", "gx", function()
    -- Get the text under cursor
    local line = vim.fn.getline(".")
    local col = vim.fn.col(".")
    local start_col = col
    local end_col = col

    -- Find the start of the github: link
    while start_col > 0 and line:sub(start_col, start_col) ~= " " and line:sub(start_col, start_col) ~= "\t" do
        start_col = start_col - 1
    end

    -- Find the end of the github: link
    while end_col <= #line and line:sub(end_col, end_col) ~= " " and line:sub(end_col, end_col) ~= "\t" do
        end_col = end_col + 1
    end

    -- Extract the github link
    local text = line:sub(start_col + 1, end_col - 1)

    -- Check if it matches our pattern
    local match = string.match(text, "github:([%w%-_]+/[%w%-_]+)")
    if match then
        local url = "https://github.com/" .. match .. "?tab=readme-ov-file"

        -- Open the URL based on platform
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
    else
        -- Fall back to default URL opener for regular URLs
        -- Get the URL under cursor
        local url = vim.fn.expand("<cfile>")
        if url:match("^https?://") or url:match("^www%.") then
            -- Open the URL based on platform
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
        else
            -- Let Neovim try to handle it with its default behavior
            local saved_map = vim.fn.maparg("gx", "n", false, true)
            vim.keymap.del("n", "gx")
            vim.cmd("normal! gx")
            if saved_map and saved_map.buffer == 0 then
                vim.keymap.set(
                    "n",
                    "gx",
                    saved_map.rhs,
                    { noremap = saved_map.noremap, silent = saved_map.silent, expr = saved_map.expr }
                )
            end
        end
    end
end, { noremap = true, silent = true, desc = "Open GitHub URL" })

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

keymap({ "n", "v" }, "<leader>e", "<cmd>LazyExtra<CR>", { desc = "Open Lazy Extra menu" })

keymap({ "n", "v" }, "<leader>r", "<cmd>source $MYVIMRC<CR>", { desc = "Reload vim config" })

keymap("n", "<leader>cw", ":%s/^\\s\\+$//e<CR>", { desc = "Clear whitespace-only lines" })
