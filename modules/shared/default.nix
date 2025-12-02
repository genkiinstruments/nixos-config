{
  pkgs,
  flake,
  hostName,
  ...
}:
{
  # Primary substituters used by default
  nix.settings.substituters = [ "https://harmonia.genki.is" ];
  nix.settings.trusted-substituters = [ "https://harmonia.genki.is" ]; # Caches in trusted-substituters can be used by unprivileged users i.e. in flakes but are not enabled by default.
  nix.settings.trusted-public-keys = [
    "harmonia.genki.is:qrZRBDHwHxClL6tsMgFhcFrA61YzyP/ATE2JHDYB5iQ="
  ];

  nix.package = pkgs.nixVersions.latest;

  # This is not set by default in blueprint
  networking.hostName = hostName;

  users.users.root.openssh.authorizedKeys.keyFiles = [ "${flake}/authorized_keys" ];

  # Disallow IFDs by default. IFDs can too easily sneak in and cause trouble.
  # https://nix.dev/manual/nix/2.22/language/import-from-derivation
  nix.settings.allow-import-from-derivation = false;

  services.tailscale.enable = true; # Deploy tailscale everywhere
}
