{ config, pkgs, user, ... }:

{
  imports = [ 
  ./dock 
  ../shared/home-manager.nix 
  ];

  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ1uxevLNJOPIPRMh9G9fFSqLtYjK5R7+nRdtsas2KwX" ];
  };

  homebrew = {
    enable = true;
    casks = [ "shortcat" "raycast" "arc" ];
    masApps = {
      # `nix run nixpkgs#mas -- search <app name>`
      "Keynote" = 409183694;
      "ColorSlurp" = 1287239339;
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    users.${user} = { ... }:
      {
        home.enableNixpkgsReleaseCheck = false;
        home.stateVersion = "23.05";

        home.file.".config/karabiner/karabiner.json".source = ./config/karabiner/karabiner.json; # Hyper-key config

        xdg.enable = true; # Needed for fish interactiveShellInit hack
      };
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
