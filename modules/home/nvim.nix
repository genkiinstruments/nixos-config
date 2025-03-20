{ flake, ... }:
{
  pkgs,
  config,
  lib,
  ...
}:
let
  nvim-lsp-packages = flake.lib.nvim-lsp-packages { inherit pkgs; };
  treesitter-grammars = flake.lib.treesitter-grammars { inherit pkgs; };
  neovim = flake.lib.neovim { inherit pkgs; };
  cfg = config.programs.mvim;
in
{
  options.programs.mvim = {
    configFullPath = lib.mkOption {
      type = lib.types.str;
      description = "Full path to nixos-config repository";
      default = "/etc/nixos-config";
    };
  };

  config = {
    home.packages = nvim-lsp-packages ++ [
      neovim
      pkgs.git
    ];

    # Keep the treesitter grammar source
    xdg.dataFile."nvim/site/parser".source = treesitter-grammars;

    # Use Home Manager's dag system to ensure proper ordering
    home.activation.nvimSetup = config.lib.dag.entryAfter [ "writeBoundary" ] ''
      echo "Setting up Neovim configuration..."
      NVIM_CONFIG_PATH="${config.xdg.configHome}/nvim"
      NVIM_CONFIG_SOURCE="${cfg.configFullPath}/home/nvim"

      # Debug information
      echo "NVIM_CONFIG_PATH: $NVIM_CONFIG_PATH"
      echo "NVIM_CONFIG_SOURCE: $NVIM_CONFIG_SOURCE"

      # Check for and remove the circular symlink
      if [ -L "$NVIM_CONFIG_SOURCE/nvim" ]; then
        echo "Found circular symlink at $NVIM_CONFIG_SOURCE/nvim, removing it"
        TARGET=$(readlink "$NVIM_CONFIG_SOURCE/nvim")
        echo "It points to: $TARGET"
        rm -f "$NVIM_CONFIG_SOURCE/nvim"
        echo "Circular symlink removed"
      fi

      # Double-check it's gone
      if [ -L "$NVIM_CONFIG_SOURCE/nvim" ]; then
        echo "ERROR: Failed to remove circular symlink!"
        ls -la "$NVIM_CONFIG_SOURCE"
        exit 1
      fi

      # Set up the main symlink from ~/.config/nvim to our config directory
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
      echo "${treesitter-grammars.rev}" > "$NVIM_CONFIG_SOURCE/treesitter-rev"

      # Update plugins if needed
      if [[ -f "$NVIM_CONFIG_SOURCE/lazy-lock.json" ]]; then
        if ! grep -q "${treesitter-grammars.rev}" "$NVIM_CONFIG_SOURCE/lazy-lock.json"; then
          ${neovim}/bin/nvim --headless "+Lazy! update" +qa > /dev/null 2>&1
        fi
      fi

      # Final check to make sure circular symlink didn't somehow get recreated
      if [ -L "$NVIM_CONFIG_SOURCE/nvim" ]; then
        echo "WARNING: Circular symlink was recreated! Removing again..."
        rm -f "$NVIM_CONFIG_SOURCE/nvim"
      fi
    '';
  };
}
