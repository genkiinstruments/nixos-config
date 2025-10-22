{
  flake,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    flake.modules.home.default
    flake.modules.home.mvim
  ];

  # Enable mvim with home-manager integration and custom config path
  programs.mvim = {
    enable = true;
    configPath = "/Users/saumavel/genkiinstruments/nixos-config/hosts/saumavel/users";
    appName = "nvim";
  };

  home.file.".config/karabiner/karabiner.json".source = lib.mkForce ./karabiner.json;

  # XDG Base Directory specification configuration
  # Manages application configurations and default applications
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
        ktmux = "~/development/scripts/tmux-katla";
        n = "nvim";
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

    git = {
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
  home.packages = with pkgs; [
    pstree # Display running processes as a tree
    tldr
  ];
}
