{
  flake,
  pkgs,
  lib,
  perSystem,
  ...
}:
{
  imports = [
    flake.modules.home.default
  ];

  home.packages = with pkgs; [
    go
    nixfmt
    nodejs
    mermaid-cli
    imagemagick
    pstree # Display running processes as a tree
    rust-analyzer
    tectonic
    tree-sitter
    tldr
    ast-grep
    ghostscript
    perSystem.self.nvim-saumavel
  ];

  home.file.".config/karabiner/karabiner.json".source = lib.mkForce ./karabiner.json;

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
      shellAliases = {
        n = lib.mkForce "nvim";
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
      font.size = lib.mkForce 16; # override stylix default
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
    };
  };

  # NOTE: Use this to add packages available everywhere on your system
  # $search nixpkgs {forrit}
  # https://search.nixos.org/packages
}
