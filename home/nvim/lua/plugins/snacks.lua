return {
    "folke/snacks.nvim",
    opts = {
        dashboard = {
            preset = {
                header = [[
        ███╗   ███╗██╗   ██╗██╗███╗   ███╗          M
        ████╗ ████║██║   ██║██║████╗ ████║      M    
        ██╔████╔██║██║   ██║██║██╔████╔██║   m       
        ██║╚██╔╝██║╚██╗ ██╔╝██║██║╚██╔╝██║ m         
        ██║ ╚═╝ ██║ ╚████╔╝ ██║██║ ╚═╝ ██║           
        ╚═╝     ╚═╝  ╚═══╝  ╚═╝╚═╝     ╚═╝           
 ]],
            },
        },
        -- Disable image functionality since dependencies are missing
        explorer = {
            enabled = false,
        },
        picker = {
            enabled = false,
        },
        statuscolumn = {
            enabled = false,
        },
    },
}
