{
  pkgs,
  flake,
}:
with pkgs;
let
  treesitter-grammars = flake.lib.treesitter-grammars { inherit pkgs; };
  nvim-lsp-packages = flake.lib.nvim-lsp-packages { inherit pkgs; };
  neovim = flake.lib.neovim { inherit pkgs; };
  lspEnv = pkgs.buildEnv {
    name = "lsp-servers";
    paths = nvim-lsp-packages;
  };
  name = "mvim";
in
writeShellApplication {
  inherit name;
  text = ''
    set -efu
    unset VIMINIT
    export PATH="${pkgs.coreutils}/bin:${lspEnv}/bin:${neovim}/bin:$PATH"
    export NVIM_APPNAME=${name}

    XDG_CONFIG_HOME=''${XDG_CONFIG_HOME:-$HOME/.config}
    XDG_DATA_HOME=''${XDG_DATA_HOME:-$HOME/.local/share}

    # Safety checks for required variables
    if [ -z "$XDG_CONFIG_HOME" ] || [ -z "$NVIM_APPNAME" ]; then
      echo "Error: XDG_CONFIG_HOME or NVIM_APPNAME is not set" >&2
      exit 1
    fi

    # Ensure we're not accidentally deleting root directory
    CONFIG_DIR="$XDG_CONFIG_HOME/$NVIM_APPNAME"
    if [ "$CONFIG_DIR" = "/" ] || [ -z "$CONFIG_DIR" ]; then
      echo "Error: Invalid config directory path" >&2
      exit 1
    fi

    mkdir -p "$CONFIG_DIR" "$XDG_DATA_HOME"
    chmod -R u+w "$CONFIG_DIR"
    rm -rf "$CONFIG_DIR"
    cp -arfT '${flake}/home/nvim/' "$CONFIG_DIR"
    chmod -R u+w "$CONFIG_DIR"
    echo "${treesitter-grammars.rev}" > "$CONFIG_DIR/treesitter-rev"

    # Always ensure lazy.nvim is properly initialized first
    # This is crucial for CI environments where the plugin might not be installed
    LAZY_NVIM_DIR="$XDG_DATA_HOME/$NVIM_APPNAME/lazy/lazy.nvim"
    if [ ! -d "$LAZY_NVIM_DIR" ]; then
      mkdir -p "$(dirname "$LAZY_NVIM_DIR")"
      git clone --filter=blob:none --branch=stable https://github.com/folke/lazy.nvim.git "$LAZY_NVIM_DIR"
    fi

    # Then check if we need to update
    if ! grep -q "${treesitter-grammars.rev}" "$CONFIG_DIR/lazy-lock.json"; then
      nvim --headless "+Lazy! update" +qa > /dev/null 2>&1 &
    else
      nvim --headless -c 'quitall' > /dev/null 2>&1
    fi

    mkdir -p "$XDG_DATA_HOME/$NVIM_APPNAME/lib/" "$XDG_DATA_HOME/$NVIM_APPNAME/site/"

    PARSER_DIR="$XDG_DATA_HOME/$NVIM_APPNAME/site/parser"

    # If the parser directory exists, move it to a backup location instead of trying to modify it
    if [ -d "$PARSER_DIR" ]; then
      mv "$PARSER_DIR" "$PARSER_DIR.old" 2>/dev/null || true
    fi

    # Create the symlink using GNU ln
    ln -sfn "${treesitter-grammars}" "$PARSER_DIR"

    exec nvim "$@"
  '';
}
