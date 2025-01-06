{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;

  nix.settings.substituters = [
    "https://genki.cachix.org"
    "https://nix-community.cachix.org"
    "https://cache.nixos.org"
  ];
  nix.settings.trusted-public-keys = [
    "genki.cachix.org-1:5l+wAa4rDwhcd5Wm43eK4N73qJ6GIKmJQ87Nw/bRGfE="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  ];
  nix.settings.experimental-features = lib.mkDefault "nix-command flakes";

  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

  # Deploy tailscale everywhere
  services.tailscale.enable = true;

  programs.fish.enable = true; # Otherwise our shell won't be installed correctly

  # Configure home-manager
  home-manager.extraSpecialArgs.inputs = inputs; # forward the inputs
  home-manager.useGlobalPkgs = true; # don't create another instance of nixpkgs
  home-manager.useUserPackages = true; # install user packages directly to the user's profile
  home-manager.backupFileExtension = "backup";
}
