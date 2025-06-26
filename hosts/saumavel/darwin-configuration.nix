{
  flake,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.srvos.darwinModules.common
    inputs.srvos.darwinModules.mixins-terminfo
    flake.modules.darwin.default
    flake.modules.darwin.secretive
    flake.modules.shared.default
    flake.modules.shared.home-manager
  ];

  # Add the unfree configuration here
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "copilot.vim"
    ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  system.primaryUser = "saumavel";

  users.users.saumavel = {
    isHidden = false;
    home = "/Users/saumavel";
    shell = pkgs.fish;
  };

  # Fix nixbld group ID issue
  ids.gids.nixbld = 350;

  # Modified homebrew configuration to update but not remove packages
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true; # Update Homebrew and formulae
      upgrade = true; # Upgrade outdated packages
      cleanup = "none"; # Don't remove any packages not in the list
    };
    brews = [
      "nvm"
      "node"
      "clang-format"
      "hashcat"
      "qemu"
      "luarocks"
      "biber"
      "texlive"
      "xdotool"
    ];
    casks = [
      # MEGA UTILITIES
      "raycast"
      "alt-tab"
      "karabiner-elements"
      "shortcat"
      "screen-studio"

      # UTILITIES
      "keyboardcleantool"
      "logi-options+"
      "the-unarchiver"
      "postman"

      # TERMINALS
      "ghostty"
      "kitty"

      # WORK
      "obsidian"
      "slack"
      "linear-linear"

      # BROWSERS
      "arc"

      # CHAT
      "messenger"

      # FUN
      "bitwig-studio"
      "plex"

      # IDE´s
      "zed"
      "visual-studio-code"
    ];
    masApps = {
      # `nix run nixpkgs #mas -- search <app name>`
      "Keynote" = 409183694;
      "Pages" = 409201541;
    };
  };
}
