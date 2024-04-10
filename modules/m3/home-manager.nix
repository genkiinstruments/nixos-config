{ config, pkgs, user, name, email, ... }:

{
  imports = [
    ./dock
  ];

  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.fish;
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

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;

    users.${user} = { pkgs, config, lib, ... }:
      (import ../shared/home-manager.nix { inherit config pkgs lib user name email; }) // {
        home.enableNixpkgsReleaseCheck = false;
        home.packages = with pkgs; let shared-packages = import ../shared/packages.nix { inherit pkgs; }; in shared-packages ++ [ dockutil ];
        home.stateVersion = "23.05";
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
