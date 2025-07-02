{
  pkgs,
  flake,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;

  # Primary substituters used by default
  nix.settings.substituters = [ "https://x.tail01dbd.ts.net:8443/genki" ];

  # Caches in trusted-substituters can be used by unprivileged users i.e. in flakes but are not enabled by default.
  nix.settings.trusted-substituters = [ "https://x.tail01dbd.ts.net:8443/genki" ];
  nix.settings.trusted-public-keys = [ "genki:S03n+SoctaWEOjLRWLFTbd898DdDMn5r/L2T+cj1IHE=" ];

  users.users.root.openssh.authorizedKeys.keyFiles = [ "${flake}/authorized_keys" ];

  # Disallow IFDs by default. IFDs can too easily sneak in and cause trouble.
  # https://nix.dev/manual/nix/2.22/language/import-from-derivation
  nix.settings.allow-import-from-derivation = false;

  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

  services.tailscale.enable = true; # Deploy tailscale everywhere

  programs.fish.shellInit = ''
    # Nix
    if test -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
      source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
    end
    # End Nix
  '';

  environment.shells = with pkgs; [
    bashInteractive
    zsh
    fish
  ];
}
