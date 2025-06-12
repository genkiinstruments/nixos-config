{
  flake,
  pkgs,
  ...
}:
{
  imports = [
    flake.modules.darwin.default
    flake.modules.shared.default
    flake.modules.shared.home-manager
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  networking.hostName = "d";

  users.users.genki = {
    isHidden = false;
    home = "/Users/genki";
    name = "genki";
    shell = pkgs.fish;
  };
  system.primaryUser = "genki";

  # NOTE: Here you can install packages from brew
  homebrew = {
    enable = true;
    taps = [
      # for things not in the hombrew repo, e.g.,
    ];
    casks = [
      # guis
      "raycast"
      "arc"
    ];
    brews = [
      # clis and libraries
    ];
    masApps = {
      # `nix run nixpkgs#mas -- search <app name>`
      "Keynote" = 409183694;
    };
  };
}
