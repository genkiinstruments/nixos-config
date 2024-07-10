{ pkgs, ... }:
{
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = true;
      allowInsecure = false;
      allowUnsupportedSystem = true;
    };

    # Apply each overlay found in the /overlays directory
    overlays =
      let path = ../../overlays; in with builtins;
      map (n: import (path + ("/" + n)))
        (filter
          (n: match ".*\\.nix" n != null ||
            pathExists (path + ("/" + n + "/default.nix")))
          (attrNames (readDir path)));
  };

  nix = {
    package = pkgs.nixVersions.latest;
    extraOptions =
      let empty_registry = builtins.toFile "empty-flake-registry.json" ''{"flakes":[],"version":2}''; in
      ''
        experimental-features = nix-command flakes ca-derivations impure-derivations recursive-nix
        flake-registry = ${empty_registry}
        builders-use-substitutes = true
      '';
    gc = {
      user = "root";
      automatic = true;
      interval = { Weekday = 0; Hour = 2; Minute = 0; };
      options = "--delete-older-than 30d";
    };

    settings = {
      trusted-users = [ "root" "@wheel" ];
      substituters = [
        "https://genki.cachix.org"
        "https://nix-community.cachix.org"
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [
        "genki.cachix.org-1:5l+wAa4rDwhcd5Wm43eK4N73qJ6GIKmJQ87Nw/bRGfE="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };
  };

  fonts.packages = [ (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; }) ];
}
