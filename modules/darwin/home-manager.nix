{ user, ... }:

{
  imports = [
    ../shared/home-manager.nix
  ];

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
}
