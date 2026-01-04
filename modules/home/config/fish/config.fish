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
# Git Worktree Functions
#-------------------------------------------------------------------------------
function nwt --description "Create new git worktree and open in sesh"
    if test (count $argv) -eq 0
        echo "Usage: nwt <worktree-name> [base-branch]"
        return 1
    end

    set worktree_name $argv[1]

    # cd to project root (parent of .bare)
    set git_common_dir (git rev-parse --git-common-dir 2>/dev/null)
    if test -z "$git_common_dir"
        echo "Not in a git repository"
        return 1
    end
    set project_root (dirname $git_common_dir)
    cd $project_root

    # Base branch: use arg, or pick from list
    if test (count $argv) -ge 2
        set base_branch $argv[2]
    else
        set base_branch (git branch -r --format='%(refname:short)' | fzf --prompt="Base branch: " --height=40% --reverse)
        if test -z "$base_branch"
            echo "No branch selected"
            return 1
        end
    end

    git worktree add $worktree_name -b $worktree_name $base_branch
    and cd $worktree_name
    and sesh connect .
end

function gwt --description "Fuzzy-find and switch to a git worktree via sesh"
    set worktree (git worktree list --porcelain | grep '^worktree ' | cut -d' ' -f2 | fzf --prompt="🌲 Worktree: " --height=40% --reverse)
    if test -n "$worktree"
        sesh connect $worktree
    end
end

function sc --description "Bare clone repo to ~/dev/owner/repo"
    # Use argument if provided, otherwise clipboard
    if test (count $argv) -gt 0
        set url $argv[1]
    else
        set url (pbpaste)
    end

    # Normalize URL: add git@ prefix if just github.com:owner/repo
    if string match -q -r '^github\.com:' $url
        set url "git@$url"
    end

    # Add .git suffix if missing
    if not string match -q '*.git' $url
        set url "$url.git"
    end

    # Extract owner/repo from various GitHub URL formats
    # Handles: git@github.com:owner/repo.git, https://github.com/owner/repo.git
    set owner_repo (echo $url | sed -E 's#^(git@github\.com:|https://github\.com/)##' | sed 's/\.git$//')

    if test -z "$owner_repo"; or not string match -q '*/*' $owner_repo
        echo "Could not parse GitHub URL: $url"
        return 1
    end

    set owner (echo $owner_repo | cut -d'/' -f1)
    set repo (echo $owner_repo | cut -d'/' -f2)
    set repo_path ~/dev/$owner/$repo

    echo "Bare cloning $url to $repo_path"

    # Create directory
    mkdir -p $repo_path
    cd $repo_path

    # Clone as bare repo
    git clone --bare $url .bare

    # Create .git file pointing to bare repo
    echo "gitdir: ./.bare" >.git

    # Configure fetch to get all branches
    git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
    git fetch origin

    echo "Done! Create a worktree with: nwt <name>"
    sesh connect .
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
