{
  pkgs,
  pname,
  flake,
  ...
}:
pkgs.writeShellApplication {
  name = pname;
  runtimeInputs = with pkgs; [
    neovim
    go
    cargo
    nodejs
    nixfmt
    rust-analyzer
    ast-grep
    lua5_1
    luarocks
  ];
  text = ''
    # Set NVIM_APPNAME to use custom config
    export NVIM_APPNAME=${pname}

    # Set up config symlink if it doesn't exist
    NVIM_CONFIG_PATH="''${XDG_CONFIG_HOME:-$HOME/.config}/$NVIM_APPNAME"

    # Determine config source: use MVIM_CONFIG_SOURCE if set, otherwise nix store
    if [ -n "''${MVIM_CONFIG_SOURCE:-}" ]; then
      NVIM_CONFIG_SOURCE="$MVIM_CONFIG_SOURCE"
    else
      NVIM_CONFIG_SOURCE="${flake}/home/nvim"
    fi

    if [ ! -e "$NVIM_CONFIG_PATH" ]; then
      echo "Creating config symlink at $NVIM_CONFIG_PATH"
      ln -sfn "$NVIM_CONFIG_SOURCE" "$NVIM_CONFIG_PATH"
    fi

    # Launch neovim with all arguments passed through
    exec nvim "$@"
  '';
  meta = {
    description = "Multivacs Meovim";
    mainProgram = pname;
  };
}
