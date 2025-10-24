-- ============================================================================
-- Snacks.nvim Configuration
-- ============================================================================
-- Collection of small utilities including dashboard, picker, and more
return {
    "folke/snacks.nvim",
    event = "VimEnter",
    enabled = true,
    opts = {
        -- ====================================================================
        -- Picker Configuration
        -- ====================================================================
        picker = {
            -- Configure picker sources with per-directory filtering
            sources = {
                oldfiles = {
                    -- Filter recent files to only show files from current directory
                    filter = function(item)
                        local cwd = vim.fn.getcwd()
                        return vim.startswith(item.file, cwd)
                    end,
                },
            },
        },

        -- ====================================================================
        -- Dashboard Configuration
        -- ====================================================================
        dashboard = {
            enabled = true,
            width = 60,
            row = nil,
            col = nil,
            pane_gap = 4,
            autokeys = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",

            -- ----------------------------------------------------------------
            -- Preset Configuration
            -- ----------------------------------------------------------------
            preset = {
                -- ASCII art header for dashboard
                header = [[

  ,================.P ''  111000010101001110001110101001  '' P _________________
  |\HELLTARI_00100/| L''  ‡‡‡‡‡ÞgG‡``````````````ül***¯‹  ''L /' ,__________,  '\
  |.--------------.|  E'  ü66GÅÆ````***```3l`ü*```ü33‡**  'E  | '            `  |
  ||[ _    .  _ ]_||  'A  gÆ````````````````````‹¯*`6`‡*  A'  | |  WELCOME   |  |
  |`--------------'|  ''S Æ``‹```gÆÆÆÆÆÆÆÆÆÆÆÆÆÆÆ````Çü* S''  | |    TO      |  |
  ||  I   C   U   ||  '' EÆ``````‹gÆgGgGÆgÅÆÅÆÆÆÆÆ````ülE ''  | |  HEEEELL!  |  |
  |`------------_-'|K ''  gÆ``````ÆÆÆÆÆÆÆÆÆÆÆÆÆÆÆÆÆ``¯Ç*  '' K| |            |  |
  ||[=====| o  (@) | I''  ÇÆ````6ÞÆÆÆÆÆÆgGG```````Æ``¯‹*  ''I | `,__________,'  |
  |`------'/u\ --- |  I'  lÆÇ```````````ÆÆ‹``````ÆÆÆ`Æ`l  'I  |    _______      |
  |----------------|  'I  üÆ``````‹`ÆÆ``ÆÆÆÆÆÆÆÆÆÆÆÅ`Æ`¯  L'  |<> [___=___](@)<>|
  | (/)          []|  ''L 6gÆ```6ÆÆÆÆÆ```ÆÆÆÆÆÆÆÅÆÆ`ÆÆ`* L''  ':________________/
  |---===--------==|  '' L3‡ÅÇ```¯ÆÆÆ````Æ``ÆgGÅÆÆÆ`Æ``*L ''    (____________)
  |WELCOME/\/\/\/\/|M ''  3üÇÅÆ```‡ÆÆ‹```ÆÆÆÆÆÆÆÆÆG```*l  '' M ___________/______
  |/\/\/\/\TO/\/\/\| E''  ü‡‡3Å``````````6`````ÆÆÅÆ`¯*¯*  ''E /''''=========='(@)\
  |\/\/\/\/\/\HELL||  E'  3l‡üü```‹gÇÞ`GÆgÆÆÆÆ`Ggü``‡l**  'E  |[][][][][][][][][]|
  |/\/\/\/\/\/\/\/\|  'E  ü6‡ü6l`````*`*ÆÅÆÆ63```ÅÆ```Ç*  E'  |[][][][][][][][][]|
  |================|  ''E 3336Å`````````````````‹ÆÆ```ÆÇ E''  |[][][][][][][][][]|
 .'                `. '' !110100011101010011101000011110! ''  \------------------/
]],

                -- --------------------------------------------------------
                -- Dashboard Key Actions
                -- --------------------------------------------------------
                keys = {
                    {
                        icon = "󰋚",
                        key = "r",
                        desc = "Recent Files",
                        action = ":lua Snacks.dashboard.pick('oldfiles')",
                    },
                    {
                        icon = "󰈞 ",
                        key = "f",
                        desc = "Find File",
                        action = ":lua Snacks.dashboard.pick('files')",
                    },
                    {
                        icon = "󰊄",
                        key = "g",
                        desc = "Find Text",
                        action = ":lua Snacks.dashboard.pick('live_grep')",
                    },
                    {
                        icon = "󰮗",
                        key = "c",
                        desc = "Config",
                        action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
                    },
                    {
                        icon = "󰉋",
                        key = "e",
                        desc = "Open Oil",
                        action = ":lua require('oil').open()",
                    },
                    {
                        icon = "󰒲",
                        key = "l",
                        desc = "Lazy",
                        action = ":Lazy",
                        enabled = package.loaded.lazy ~= nil,
                    },
                    {
                        icon = "󰒲",
                        key = "x",
                        desc = "Lazy Extra",
                        action = ":LazyExtra",
                        enabled = package.loaded.lazy ~= nil,
                    },
                    {
                        icon = "󰗼",
                        key = "q",
                        desc = "Quit",
                        action = ":qa",
                    },
                },
            },
            -- ----------------------------------------------------------------
            -- Format Configuration
            -- ----------------------------------------------------------------
            formats = {
                key = { "%s", align = "center" },
                desc = { "%s", align = "center" },
                icon = { "%s", align = "center" },
            },

            -- ----------------------------------------------------------------
            -- Layout Sections
            -- ----------------------------------------------------------------
            sections = {
                -- Header section
                {
                    section = "header",
                    pane = 1,
                },
                -- Keys section (positioned below header)
                {
                    section = "keys",
                    gap = 1,
                    padding = 1,
                    pane = 1,
                    align = "center",
                    row = 20,
                },
                -- Startup info section (positioned below keys)
                {
                    section = "startup",
                    pane = 1,
                    row = 30,
                },
            },
        },
    },

    -- ========================================================================
    -- Setup Function
    -- ========================================================================
    config = function(_, opts)
        require("snacks").setup(opts)
    end,
}
