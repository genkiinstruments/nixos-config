{
  pkgs,
  lib,
  flake,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;

  nix.settings.substituters = [
    "https://nix-community.cachix.org"
    "https://cache.nixos.org"
  ];
  nix.settings.trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  ];
  nix.settings.experimental-features = lib.mkDefault "nix-command flakes";

  users.users.root.openssh.authorizedKeys.keyFiles = [ "${flake}/authorized_keys" ];

  # Disallow IFDs by default. IFDs can too easily sneak in and cause trouble.
  # https://nix.dev/manual/nix/2.22/language/import-from-derivation
  nix.settings.allow-import-from-derivation = false;

  # If the user is in @wheel they are trusted by default.
  nix.settings.trusted-users = [ "@wheel" ];

  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

  services.tailscale.enable = true; # Deploy tailscale everywhere
}
