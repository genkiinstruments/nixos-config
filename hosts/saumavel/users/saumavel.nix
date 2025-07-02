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
    flake.modules.home.fish-ssh-agent
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
    fish.shellAliases.cppbuild = "g++ -std=c++17 -Wall -Wextra";

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

    tmux = {
      shortcut = "a";
      # status.enable = false;
    };

    git = {
      userName = "saumavel";
      userEmail = "saumavel@gmail.com";
      extraConfig.github.user = "saumavel";
      delta.enable = true;
    };
  };

  # NOTE: Use this to add packages available everywhere on your system
  # $search nixpkgs {forrit}
  # https://search.nixos.org/packages
  home.packages = with pkgs; [
    pstree # Display running processes as a tree
  ];
}
