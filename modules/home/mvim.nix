{ flake, ... }:
{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.programs.mvim;
  mvimBase = flake.lib.mvim-base {
    inherit flake pkgs lib;
    configSource = "${cfg.configPath}/home/nvim";
    NVIM_APPNAME = cfg.appName;
  };
in
{
  options.programs.mvim = {
    enable = lib.mkEnableOption "mvim with home-manager integration";

    configPath = lib.mkOption {
      type = lib.types.str;
      description = "Path to the nixos-config repository containing nvim config";
      example = "/Users/username/nixos-config";
    };

    appName = lib.mkOption {
      type = lib.types.str;
      description = "NVIM_APPNAME value - determines where neovim looks for config";
      example = "mvim";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = mvimBase.commonPackages;

    # Set up environment variables (but don't override PATH)
    home.sessionVariables = {
      NVIM_APPNAME = mvimBase.commonEnvVars.NVIM_APPNAME;
    };

    # Keep the treesitter grammar source
    xdg.dataFile."${cfg.appName}/site/parser".source = mvimBase.treesitter-grammars;

    # Use Home Manager's dag system to ensure proper ordering
    home.activation.mvimSetup = config.lib.dag.entryAfter [ "writeBoundary" ] ''
      echo "Setting up mvim configuration..."
      NVIM_CONFIG_PATH="${config.xdg.configHome}/${mvimBase.commonEnvVars.NVIM_APPNAME}"
      NVIM_CONFIG_SOURCE="${cfg.configPath}/home/nvim"

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
      if [ -L "$NVIM_CONFIG_SOURCE/${mvimBase.commonEnvVars.NVIM_APPNAME}" ]; then
        echo "Found circular symlink at $NVIM_CONFIG_SOURCE/${mvimBase.commonEnvVars.NVIM_APPNAME}, removing it"
        TARGET=$(readlink "$NVIM_CONFIG_SOURCE/${mvimBase.commonEnvVars.NVIM_APPNAME}")
        echo "It points to: $TARGET"
        rm -f "$NVIM_CONFIG_SOURCE/${mvimBase.commonEnvVars.NVIM_APPNAME}"
        echo "Circular symlink removed"
      fi

      # Double-check it's gone
      if [ -L "$NVIM_CONFIG_SOURCE/${mvimBase.commonEnvVars.NVIM_APPNAME}" ]; then
        echo "ERROR: Failed to remove circular symlink!"
        ls -la "$NVIM_CONFIG_SOURCE"
        exit 1
      fi

      # Set up the main symlink from ~/.config/mvim to our config directory
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

      # Write the treesitter revision
      echo "${mvimBase.treesitter-grammars.rev}" > "$NVIM_CONFIG_SOURCE/treesitter-rev"

      # Update plugins if needed
      if [[ -f "$NVIM_CONFIG_SOURCE/lazy-lock.json" ]]; then
        if ! ${pkgs.gnugrep}/bin/grep -q "${mvimBase.treesitter-grammars.rev}" "$NVIM_CONFIG_SOURCE/lazy-lock.json"; then
          ${mvimBase.neovim}/bin/nvim --headless "+Lazy! update" +qa > /dev/null 2>&1
        fi
      fi

      # Final check to make sure circular symlink didn't somehow get recreated
      if [ -L "$NVIM_CONFIG_SOURCE/${mvimBase.commonEnvVars.NVIM_APPNAME}" ]; then
        echo "WARNING: Circular symlink was recreated! Removing again..."
        rm -f "$NVIM_CONFIG_SOURCE/${mvimBase.commonEnvVars.NVIM_APPNAME}"
      fi
    '';
  };
}
