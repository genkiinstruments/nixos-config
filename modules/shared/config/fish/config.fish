# I want my nix binaries to be found first in the nix path
fish_add_path --path --move /run/current-system/sw/bin

#-------------------------------------------------------------------------------
# SSH Agent
#-------------------------------------------------------------------------------
function __ssh_agent_is_started -d "check if ssh agent is already started"
    if begin
            test -f $SSH_ENV; and test -z "$SSH_AGENT_PID"
        end
        source $SSH_ENV >/dev/null
    end

    if test -z "$SSH_AGENT_PID"
        return 1
    end

    ssh-add -l >/dev/null 2>&1
    if test $status -eq 2
        return 1
    end
end

function __ssh_agent_start -d "start a new ssh agent"
    ssh-agent -c | sed 's/^echo/#echo/' >$SSH_ENV
    chmod 600 $SSH_ENV
    source $SSH_ENV >/dev/null
    ssh-add
end

if not test -d $HOME/.ssh
    mkdir -p $HOME/.ssh
    chmod 0700 $HOME/.ssh
end

if test -d $HOME/.gnupg
    chmod 0700 $HOME/.gnupg
end

if test -z "$SSH_ENV"
    set -xg SSH_ENV $HOME/.ssh/environment
end

if not __ssh_agent_is_started
    __ssh_agent_start
end

#-------------------------------------------------------------------------------
# Ghostty Shell Integration
#-------------------------------------------------------------------------------
# Ghostty supports auto-injection but Nix-darwin hard overwrites XDG_DATA_DIRS
# which make it so that we can't use the auto-injection. We have to source
# manually.
if set -q GHOSTTY_RESOURCES_DIR
    source "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish"
end

#-------------------------------------------------------------------------------
# Programs
#-------------------------------------------------------------------------------
# Vim: We should move this somewhere else but it works for now
mkdir -p $HOME/.vim/{backup,swap,undo}

# Homebrew
if test -d /opt/homebrew
    set -gx HOMEBREW_PREFIX /opt/homebrew
    set -gx HOMEBREW_CELLAR /opt/homebrew/Cellar
    set -gx HOMEBREW_REPOSITORY /opt/homebrew
    set -q PATH; or set PATH ''
    set -gx PATH /opt/homebrew/bin /opt/homebrew/sbin $PATH
    set -q MANPATH; or set MANPATH ''
    set -gx MANPATH /opt/homebrew/share/man $MANPATH
    set -q INFOPATH; or set INFOPATH ''
    set -gx INFOPATH /opt/homebrew/share/info $INFOPATH
end

# Hammerspoon
if test -d "/Applications/Hammerspoon.app"
    set -q PATH; or set PATH ''
    set -gx PATH "/Applications/Hammerspoon.app/Contents/Frameworks/hs" $PATH
end

# Add ~/.local/bin
set -q PATH; or set PATH ''
set -gx PATH "$HOME/.local/bin" $PATH

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
