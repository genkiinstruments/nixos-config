-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- Disable swap files
vim.opt.swapfile = false

-- Configure clipboard with improved OSC52 support for SSH sessions
vim.opt.clipboard = "unnamedplus"

-- Check if the vim.clipboard.osc52 module exists (only in newer Neovim versions)
local has_osc52 = pcall(require, "vim.clipboard.osc52")

if vim.env.SSH_TTY then
    -- Create a universal clipboard provider that works in all environments
    vim.g.clipboard = {
        name = "OSC 52 Universal",
        copy = {
            ["+"] = function(lines)
                -- Join the lines with newlines
                local text = table.concat(lines, "\n")
                
                -- Try to use the built-in OSC52 if available
                if has_osc52 then
                    local osc52 = require("vim.clipboard.osc52")
                    return osc52.copy("+", {
                        max_payload = 0,
                        timeout_ms = 100
                    })(lines)
                else
                    -- Fallback implementation for older Neovim
                    local encoded = vim.fn.system("base64", text)
                    encoded = string.gsub(encoded, "\n", "")
                    -- Send the OSC52 escape sequence to the terminal
                    vim.fn.chansend(vim.v.stderr, "\x1b]52;c;" .. encoded .. "\x07")
                    return 0
                end
            end,
            ["*"] = function(lines)
                -- Same implementation for * register
                local text = table.concat(lines, "\n")
                
                if has_osc52 then
                    local osc52 = require("vim.clipboard.osc52")
                    return osc52.copy("*", {
                        max_payload = 0,
                        timeout_ms = 100
                    })(lines)
                else
                    local encoded = vim.fn.system("base64", text)
                    encoded = string.gsub(encoded, "\n", "")
                    vim.fn.chansend(vim.v.stderr, "\x1b]52;c;" .. encoded .. "\x07")
                    return 0
                end
            end,
        },
        paste = {
            ["+"] = function()
                -- First try pbpaste (macOS), then xclip (Linux)
                local mac_cmd = vim.fn.executable("pbpaste") == 1
                if mac_cmd then
                    return { vim.fn.system("pbpaste") }
                else
                    -- Check if xclip is available
                    if vim.fn.executable("xclip") == 1 then
                        return { vim.fn.system("xclip -selection clipboard -o") }
                    end
                    -- Return empty if no paste command is available
                    return { "" }
                end
            end,
            ["*"] = function()
                -- First try pbpaste (macOS), then xclip (Linux)
                local mac_cmd = vim.fn.executable("pbpaste") == 1
                if mac_cmd then
                    return { vim.fn.system("pbpaste") }
                else
                    -- Check if xclip is available
                    if vim.fn.executable("xclip") == 1 then
                        return { vim.fn.system("xclip -selection primary -o") }
                    end
                    -- Return empty if no paste command is available
                    return { "" }
                end
            end,
        },
    }
end

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
