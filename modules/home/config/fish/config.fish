#-------------------------------------------------------------------------------
# Prompt
#-------------------------------------------------------------------------------
# Do not show any greeting
set fish_greeting

# bind to ctrl-p in normal and insert mode, add any other bindings you want here too
bind \cp _atuin_search
bind -M insert \cp _atuin_search
bind \cr _atuin_search
bind -M insert \cr _atuin_search

# Use Ctrl-f to complete a suggestion in vi mode
bind -M insert \cf accept-autosuggestion

function fish_user_key_bindings
    fish_vi_key_bindings
end

set fish_vi_force_cursor
set fish_cursor_default block blink
set fish_cursor_insert line blink
set fish_cursor_replace_one underscore blink
set fish_cursor_visual block

#-------------------------------------------------------------------------------
# Vars
#-------------------------------------------------------------------------------
# Modify our path to include our Go binaries
contains $HOME/code/go/bin $fish_user_paths; or set -Ua fish_user_paths $HOME/code/go/bin
contains $HOME/bin $fish_user_paths; or set -Ua fish_user_paths $HOME/bin

# Exported variables
if isatty
    set -x GPG_TTY (tty)
end

# Editor
set -gx EDITOR nvim

#-------------------------------------------------------------------------------
# Functions
#-------------------------------------------------------------------------------
# Shortcut to setup a nix-shell with fish. This lets you do something like
# `fnix -p go` to get an environment with Go but use the fish shell along
# with it.
alias fnix "nix-shell --run fish"
