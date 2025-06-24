return {
    "folke/snacks.nvim",
    event = "VimEnter",
    enabled = true,
    opts = {
        dashboard = {
            enabled = true,
            width = 60,
            row = nil,
            col = nil,
            pane_gap = 4,
            autokeys = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
            preset = {
                -- Combined header with ASCII art on both sides
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
                    -- {
                    --     icon = "󰈙 ",
                    --     key = "n",
                    --     desc = "New File",
                    --     action = ":ene | startinsert",
                    -- },
                },
            },
            formats = {
                key = { "%s", align = "center" },
                desc = { "%s", align = "center" },
                icon = { "%s", align = "center" },
            },
            sections = {
                { section = "header", pane = 1 }, -- Combined header with both ASCII arts
                {
                    section = "keys",
                    gap = 1,
                    padding = 1,
                    pane = 1,
                    align = "center",
                    row = 20, -- Position the keys section below the header
                },
                {
                    section = "startup",
                    pane = 1,
                    row = 30, -- Position the startup section below the keys
                },
            },
        },
    },
    config = function(_, opts)
        require("snacks").setup(opts)
    end,
}
