# Do not show any greeting
set fish_greeting

function , --description "Shortcut: nix shell with multiple pkgs: `nix shell nixpkgs#{foo,bar,baz}`"
    if test (count $argv) -gt 0
        set packages_args
        for pkg in $argv
            set -a packages_args "nixpkgs#$pkg"
        end
        nix shell $packages_args
    else
        echo "Usage: , package1 package2 ..."
    end
end

function . --description "Shortcut for `nix run nixpkgs#foo`"
    if test (count $argv) -gt 0
        set package $argv[1]
        nix run nixpkgs#$package
    else
        echo "Usage: . package_name"
    end
end

#-------------------------------------------------------------------------------
# Atuin keybindings
#-------------------------------------------------------------------------------
# bind to ctrl-p in normal and insert mode
bind \cp _atuin_search
bind -M insert \cp _atuin_search
bind \cr _atuin_search
bind -M insert \cr _atuin_search

bind \cL clear

#-------------------------------------------------------------------------------
# VI keybindings
#-------------------------------------------------------------------------------
# Use Ctrl-f to complete a suggestion in vi mode
bind -M insert \cf accept-autosuggestion

fish_vi_key_bindings
set fish_vi_force_cursor
set fish_cursor_default block blink
set fish_cursor_insert line blink
set fish_cursor_replace_one underscore blink
set fish_cursor_visual block

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
    set -q PATH; or set PATH ''
    set -gx PATH /opt/homebrew/bin /opt/homebrew/sbin $PATH
    set -q MANPATH; or set MANPATH ''
    set -gx MANPATH /opt/homebrew/share/man $MANPATH
    set -q INFOPATH; or set INFOPATH ''
    set -gx INFOPATH /opt/homebrew/share/info $INFOPATH
end

# Add ~/.local/bin
set -q PATH; or set PATH ''
set -gx PATH "$HOME/.local/bin" $PATH
