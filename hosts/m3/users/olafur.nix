{
  flake,
  pkgs,
  config,
  ...
}:
{
  imports = [ flake.modules.home.default ];

  home.packages = with pkgs; [
    neovim
    go
    cargo
    nodejs
    nixfmt
    rust-analyzer
    ast-grep
  ];
  home.sessionVariables.NVIM_APPNAME = "mvim2";

  home.activation.mvimSetup =
    config.lib.dag.entryAfter [ "writeBoundary" ] # bash
      ''
        echo "Setting up mvim configuration..."
        NVIM_CONFIG_PATH="${config.xdg.configHome}/${config.home.sessionVariables.NVIM_APPNAME}"
        NVIM_CONFIG_SOURCE="/private/etc/nixos-config/home/nvim"

        # Debug information
        echo "NVIM_CONFIG_PATH: $NVIM_CONFIG_PATH"
        echo "NVIM_CONFIG_SOURCE: $NVIM_CONFIG_SOURCE"

        # Verify the config source exists
        if [ ! -d "$NVIM_CONFIG_SOURCE" ]; then
          echo "Error: Neovim config source directory not found at $NVIM_CONFIG_SOURCE"
          echo "Please check that configPath is set correctly and the directory exists"
          exit 1
        fi

        # Check for and remove any circular symlinks
        if [ -L "$NVIM_CONFIG_SOURCE/${config.home.sessionVariables.NVIM_APPNAME}" ]; then
          echo "Found circular symlink at $NVIM_CONFIG_SOURCE/${config.home.sessionVariables.NVIM_APPNAME}, removing it"
          TARGET=$(readlink "$NVIM_CONFIG_SOURCE/${config.home.sessionVariables.NVIM_APPNAME}")
          echo "It points to: $TARGET"
          rm -f "$NVIM_CONFIG_SOURCE/${config.home.sessionVariables.NVIM_APPNAME}"
          echo "Circular symlink removed"
        fi

        # Double-check it's gone
        if [ -L "$NVIM_CONFIG_SOURCE/${config.home.sessionVariables.NVIM_APPNAME}" ]; then
          echo "ERROR: Failed to remove circular symlink!"
          ls -la "$NVIM_CONFIG_SOURCE"
          exit 1
        fi

        # Set up the main symlink from ~/.config/$NVIM_APPNAME to our config directory
        if [ -e "$NVIM_CONFIG_PATH" ]; then
          if [ -L "$NVIM_CONFIG_PATH" ]; then
            # It's a symlink, check where it points
            TARGET=$(readlink "$NVIM_CONFIG_PATH")
            echo "Existing symlink at $NVIM_CONFIG_PATH points to: $TARGET"
            if [ "$TARGET" != "$NVIM_CONFIG_SOURCE" ]; then
              echo "Updating symlink to point to $NVIM_CONFIG_SOURCE"
              ln -sfn "$NVIM_CONFIG_SOURCE" "$NVIM_CONFIG_PATH"
            fi
          elif [ -d "$NVIM_CONFIG_PATH" ]; then
            echo "Error: $NVIM_CONFIG_PATH exists as a directory. Please remove it manually."
            exit 1
          else
            echo "Error: $NVIM_CONFIG_PATH exists as a file. Please remove it manually."
            exit 1
          fi
        else
          echo "Creating new symlink at $NVIM_CONFIG_PATH"
          ln -sfn "$NVIM_CONFIG_SOURCE" "$NVIM_CONFIG_PATH"
        fi

        # Final check to make sure circular symlink didn't somehow get recreated
        if [ -L "$NVIM_CONFIG_SOURCE/${config.home.sessionVariables.NVIM_APPNAME}" ]; then
          echo "WARNING: Circular symlink was recreated! Removing again..."
          rm -f "$NVIM_CONFIG_SOURCE/${config.home.sessionVariables.NVIM_APPNAME}"
        fi
      '';

  programs.git = {
    userEmail = "olafur@genkiinstruments.com";
    userName = "multivac61";
    extraConfig.github.user = "multivac61";
  };
}
