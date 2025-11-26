# Do not show any greeting
set fish_greeting

function ns --description "Shortcut: nix shell with multiple pkgs: `nix shell nixpkgs#{foo,bar,baz}`"
    if test (count $argv) -gt 0
        set packages_args
        for pkg in $argv
            set -a packages_args "nixpkgs#$pkg"
        end
        NIXPKGS_ALLOW_UNFREE=1 nix shell --impure $packages_args
    else
        echo "Usage: ns package1 package2 ..."
    end
end

function nr --description "Shortcut for `nix run nixpkgs#foo`"
    if test (count $argv) -gt 0
        set package $argv[1]
        nix run nixpkgs#$package
    else
        echo "Usage: nr package_name"
    end
end

function mkcd --description "Create directory and cd into it"
    if test (count $argv) -eq 1
        mkdir -p $argv[1] && cd $argv[1]
    else
        echo "Usage: mkcd directory_name"
    end
end

function td --description "Create temporary directory and cd into it"
    cd (mktemp -d)
end

function mksh --description "Create executable shell script with bash shebang and open in editor"
    if test (count $argv) -eq 1
        set script_name $argv[1]

        # Create the script with bash shebang and common options
        echo '#!/usr/bin/env bash' >$script_name
        echo 'set -euo pipefail' >>$script_name
        echo '' >>$script_name

        # Make it executable
        chmod u+x $script_name

        # Open in editor (prefer $EDITOR, fallback to nvim)
        if set -q EDITOR
            $EDITOR $script_name
        else
            nvim $script_name
        end
    else
        echo "Usage: mksh script_name.sh"
    end
end

#-------------------------------------------------------------------------------
# VI keybindings
#-------------------------------------------------------------------------------
set -g fish_key_bindings fish_vi_key_bindings
set fish_vi_force_cursor
set fish_cursor_default block blink
set fish_cursor_insert line blink
set fish_cursor_replace_one underscore blink
set fish_cursor_visual block

# Ctrl-f to complete a suggestion
bind -M insert ctrl-f accept-autosuggestion

# Ctrl-l to clear screen
bind -M normal ctrl-l clear
bind -M insert ctrl-l clear

#-------------------------------------------------------------------------------
# Atuin manual initialization and keybindings
#-------------------------------------------------------------------------------
# Initialize atuin, filtering out deprecated bind -k syntax
atuin init fish | sed "s/-k up/up/g" | source

# bind to ctrl-p and ctrl-r in normal and insert mode
bind -M normal ctrl-p _atuin_search
bind -M insert ctrl-p _atuin_search
bind -M normal ctrl-r _atuin_search
bind -M insert ctrl-r _atuin_search

#-------------------------------------------------------------------------------
# Ghostty Shell Integration
#-------------------------------------------------------------------------------
# Ghostty supports auto-injection but Nix-darwin hard overwrites XDG_DATA_DIRS
# which make it so that we can't use the auto-injection. We have to source
# manually.
if set -q GHOSTTY_RESOURCES_DIR
    source "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish"
end

# Homebrew
if test -d /opt/homebrew
    set -gx HOMEBREW_PREFIX /opt/homebrew
    set -gx HOMEBREW_CELLAR /opt/homebrew/Cellar
    set -gx HOMEBREW_REPOSITORY /opt/homebrew
    fish_add_path -g /opt/homebrew/bin /opt/homebrew/sbin

    set -q MANPATH; or set MANPATH ''
    set -gx MANPATH /opt/homebrew/share/man $MANPATH
    set -q INFOPATH; or set INFOPATH ''
    set -gx INFOPATH /opt/homebrew/share/info $INFOPATH
end

fish_add_path -g "$HOME/.local/bin"
