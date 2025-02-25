{ flake, ... }:
{
  pkgs,
  config,
  ...
}:
let
  nvim-lsp-packages = flake.lib.nvim-lsp-packages { inherit pkgs; };
  treesitter-grammars = flake.lib.treesitter-grammars { inherit pkgs; };
  neovim = flake.lib.neovim { inherit pkgs; };
in
{
  home.packages = nvim-lsp-packages ++ [
    neovim
    pkgs.git
  ];

  home.file.".config/nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink ./config/nvim;
    recursive = true;
  };

  home.activation.nvimSetup = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    echo "Setting up Neovim directories and permissions..."

    # Determine the correct group based on OS
    if [[ "$(uname)" == "Darwin" ]]; then
      DEFAULT_GROUP="staff"
    else
      DEFAULT_GROUP="$(id -gn)"
    fi

    # Define directories
    XDG_CONFIG_HOME=''${XDG_CONFIG_HOME:-$HOME/.config}
    XDG_DATA_HOME=''${XDG_DATA_HOME:-$HOME/.local/share}
    XDG_STATE_HOME=''${XDG_STATE_HOME:-$HOME/.local/state}
    XDG_CACHE_HOME=''${XDG_CACHE_HOME:-$HOME/.cache}
    NVIM_APPNAME=''${NVIM_APPNAME:-nvim}

    # Create main directories
    mkdir -p "$XDG_CONFIG_HOME/$NVIM_APPNAME"
    mkdir -p "$XDG_DATA_HOME/$NVIM_APPNAME"
    mkdir -p "$XDG_STATE_HOME/$NVIM_APPNAME"
    mkdir -p "$XDG_CACHE_HOME/$NVIM_APPNAME"

    # Function to safely set permissions
    safe_chmod() {
      chmod "$1" "$2" 2>/dev/null || true
    }

    safe_chown() {
      chown "$1" "$2" 2>/dev/null || true
    }

    # Set ownership and permissions for main config directory and lazy-lock.json
    safe_chown "$USER:$DEFAULT_GROUP" "$XDG_CONFIG_HOME/$NVIM_APPNAME"
    safe_chmod 755 "$XDG_CONFIG_HOME/$NVIM_APPNAME"

    # Ensure lazy-lock.json exists and has correct permissions
    touch "$XDG_CONFIG_HOME/$NVIM_APPNAME/lazy-lock.json"
    safe_chmod 644 "$XDG_CONFIG_HOME/$NVIM_APPNAME/lazy-lock.json"
    safe_chown "$USER:$DEFAULT_GROUP" "$XDG_CONFIG_HOME/$NVIM_APPNAME/lazy-lock.json"

    # Update treesitter revision
    echo "${treesitter-grammars.rev}" > "$XDG_CONFIG_HOME/$NVIM_APPNAME/treesitter-rev"
    safe_chmod 644 "$XDG_CONFIG_HOME/$NVIM_APPNAME/treesitter-rev"
    safe_chown "$USER:$DEFAULT_GROUP" "$XDG_CONFIG_HOME/$NVIM_APPNAME/treesitter-rev"

    # Set permissions for data directories
    for dir in \
      "$XDG_DATA_HOME/$NVIM_APPNAME" \
      "$XDG_DATA_HOME/$NVIM_APPNAME/lazy" \
      "$XDG_STATE_HOME/$NVIM_APPNAME" \
      "$XDG_CACHE_HOME/$NVIM_APPNAME"
    do
      mkdir -p "$dir"
      safe_chown "$USER:$DEFAULT_GROUP" "$dir"
      safe_chmod 755 "$dir"
    done

    echo "Neovim setup completed"
  '';

  home.activation.nvimUpdate = config.lib.dag.entryAfter [ "nvimSetup" ] ''
    XDG_CONFIG_HOME=''${XDG_CONFIG_HOME:-$HOME/.config}
    NVIM_APPNAME=''${NVIM_APPNAME:-nvim}

    if [[ -f $XDG_CONFIG_HOME/$NVIM_APPNAME/lazy-lock.json ]]; then
      if ! grep -q "${treesitter-grammars.rev}" "$XDG_CONFIG_HOME/$NVIM_APPNAME/lazy-lock.json"; then
        # Ensure we can write to lazy-lock.json before running the update
        chmod 644 "$XDG_CONFIG_HOME/$NVIM_APPNAME/lazy-lock.json" 2>/dev/null || true
        ${neovim}/bin/nvim --headless "+Lazy! update" +qa
      fi
    fi
  '';
}
