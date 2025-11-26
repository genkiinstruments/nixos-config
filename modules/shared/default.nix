{
  pkgs,
  flake,
  hostName,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;

  # Primary substituters used by default
  nix.settings.substituters = [ "https://attic.genki.is/genki" ];

  # Caches in trusted-substituters can be used by unprivileged users i.e. in flakes but are not enabled by default.
  nix.settings.trusted-substituters = [ "https://attic.genki.is/genki" ];
  nix.settings.trusted-public-keys = [ "genki:S03n+SoctaWEOjLRWLFTbd898DdDMn5r/L2T+cj1IHE=" ];

  nix.package = pkgs.nixVersions.latest;

  # This is not set by default in blueprint
  networking.hostName = hostName;

  users.users.root.openssh.authorizedKeys.keyFiles = [ "${flake}/authorized_keys" ];

  # Disallow IFDs by default. IFDs can too easily sneak in and cause trouble.
  # https://nix.dev/manual/nix/2.22/language/import-from-derivation
  nix.settings.allow-import-from-derivation = false;

  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

  services.tailscale.enable = true; # Deploy tailscale everywhere

  programs.fish.shellInit = ''
    # Nix - prefer nix-darwin managed nix, fall back to default profile
    if test -e '/run/current-system/sw/etc/profile.d/nix-daemon.fish'
      source '/run/current-system/sw/etc/profile.d/nix-daemon.fish'
    else if test -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
      source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
    end
  '';

  environment.shells = with pkgs; [
    bashInteractive
    zsh
    fish
  ];
}
