{ config, pkgs, user, name, email, ... }:

{
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
    users.${user} = { pkgs, config, lib, ... }:
      let
        shared = (import ../shared/home-manager.nix { inherit config pkgs lib user name email; });
      in
      {
        home = {
          enableNixpkgsReleaseCheck = false;
          stateVersion = "23.05";
          packages = with pkgs; let shared-packages = import ../shared/packages.nix { inherit pkgs; }; in shared-packages ++ [ dockutil ];

          # Hyper-key config
          file.".config/karabiner/karabiner.json".source = ./config/karabiner/karabiner.json;

        } // shared.home;

        inherit (shared) programs;
      };
  };

  # Fully declarative dock using the latest from Nix Store
  imports = [ ./dock ];

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
