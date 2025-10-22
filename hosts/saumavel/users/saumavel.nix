{
  flake,
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    flake.modules.home.default
    flake.modules.home.mvim
  ];

  home.packages = with pkgs; [
    neovim
    nixfmt
    nodejs
    imagemagick
    pstree # Display running processes as a tree
    rust-analyzer
    tree-sitter
    tldr
    ast-grep
  ];

  # Enable mvim with home-manager integration and custom config path
  # programs.mvim = {
  #   enable = true;
  #   configPath = "/Users/saumavel/genkiinstruments/nixos-config/hosts/saumavel/users";
  #   appName = "nvim";
  # };

  home = {
    file.".config/karabiner/karabiner.json".source = lib.mkForce ./karabiner.json;

    # XDG Base Directory specification configuration
    # Manages application configurations and default applications

    sessionVariables.NVIM_APPNAME = "nvim";
    activation.mvimSetup =
      config.lib.dag.entryAfter [ "writeBoundary" ] # bash
        ''
          echo "Setting up mvim configuration..."
          NVIM_CONFIG_PATH="${config.xdg.configHome}/${config.home.sessionVariables.NVIM_APPNAME}"
          NVIM_CONFIG_SOURCE="/Users/saumavel/genkiinstruments/nixos-config/hosts/saumavel/users/home/nvim"

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
  };

  xdg = {
    enable = true;
    # Default applications for file types;
    mimeApps.defaultApplications = {
      # Web application
      "text/html" = "arc.desktop";
      # plain text files
      "text/plain" = "nvim.desktop";
    };
  };

  # NOTE: START HERE: Install packages that are only available in your user environment.
  # https://home-manager-options.extranix.com/
  programs = {
    fish = {
      interactiveShellInit = ''
        # -------------------------------------------------------------------------------
        # SSH Agent - Use Secretive App
        # -------------------------------------------------------------------------------
        # This points the shell to the SSH agent socket provided by the Secretive app,
        # which stores keys in the Secure Enclave.
        set -x SSH_AUTH_SOCK $HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh

        # -------------------------------------------------------------------------------
        # Lazygit Wrapper Function
        # -------------------------------------------------------------------------------
        # This can remain, it is not related to the SSH agent.
        function lg
          set -x LAZYGIT_NEW_DIR_FILE ~/.lazygit/newdir

          lazygit $argv

          if test -f $LAZYGIT_NEW_DIR_FILE
              cd (cat $LAZYGIT_NEW_DIR_FILE)
              rm -f $LAZYGIT_NEW_DIR_FILE > /dev/null
          end
        end
      '';
      shellAliases = {
        n = "nvim";
        nv = "nvim";
        nvi = "nvim";
        nvm = "nvim";
        vim = "nvim";
      };
    };

    kitty = {
      enable = true;
      shellIntegration.enableFishIntegration = true;
      settings = {
        confirm_os_window_close = -0;
        copy_on_select = true;
        clipboard_control = "write-clipboard read-clipboard write-primary read-primary";
      };
      font = {
        size = 16.0;
        name = "JetBrainsMono Nerd Font";
      };
      extraConfig = ''
        shell /run/current-system/sw/bin/fish
      '';
    };

    delta = {
      enable = true;
      enableGitIntegration = true;
    };

    git = {
      enable = true;
      settings = {
        user.name = "saumavel";
        user.email = "saumavel@gmail.com";
        github.user = "saumavel";
      };
      delta.enable = true;
    };
  };

  # NOTE: Use this to add packages available everywhere on your system
  # $search nixpkgs {forrit}
  # https://search.nixos.org/packages
}
