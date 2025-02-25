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
    set -efux
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
    cp -arfT '${../.}' "$CONFIG_DIR"
    chmod -R u+w "$CONFIG_DIR"
    echo "${treesitter-grammars.rev}" > "$CONFIG_DIR/treesitter-rev"

    if ! grep -q "${treesitter-grammars.rev}" "$CONFIG_DIR/lazy-lock.json"; then
      nvim --headless "+Lazy! update" +qa
    else
      nvim --headless -c 'quitall'
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
