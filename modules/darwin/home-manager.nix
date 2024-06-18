{ config, pkgs, user, ... }:

{
  imports = [
    ../darwin/dock
    ../shared/home-manager.nix
  ];

  # nix-darwin specific configuration, e.g., we don't want to hide the user
  users.users.${user} = {
    isHidden = false;
    home = "/Users/${user}";
  };

  homebrew = {
    enable = true;
    casks = [ "shortcat" "raycast" "arc" "bitwarden" ];
    masApps = {
      # `nix run nixpkgs#mas -- search <app name>`
      "Keynote" = 409183694;
      "ColorSlurp" = 1287239339;
      "Numbers" = 409203825;
    };
  };

  home-manager.users.${user} = { ... }:
    {
      home.file.".config/karabiner/karabiner.json".source = ../darwin/config/karabiner/karabiner.json; # Hyper-key config
    };

  # Fully declarative dock using the latest from Nix Store
  local.dock.enable = true;
  local.dock.entries = [
    { path = "${pkgs.alacritty}/Applications/Alacritty.app/"; }
    {
      path = "${config.users.users.${user}.home}/.local/share/";
      section = "others";
      options = "--sort name --view grid --display folder";
    }
    {
      path = "${config.users.users.${user}.home}/.local/share/downloads";
      section = "others";
      options = "--sort name --view grid --display stack";
    }
  ];
}
