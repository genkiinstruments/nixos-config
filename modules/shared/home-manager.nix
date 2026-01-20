{ pkgs, ... }:
{
  programs.fish.enable = true; # Otherwise our shell won't be installed correctly
  programs.fish.useBabelfish = true; # Fish 4.x compatible - avoids fenv which is broken
  programs.fish.shellInit = /* fish */ ''
    # Nix - prefer nix-darwin managed nix, fall back to default profile
    if test -e '/run/current-system/sw/etc/profile.d/nix-daemon.fish'
      source '/run/current-system/sw/etc/profile.d/nix-daemon.fish'
    else if test -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
      source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
    end
  '';

  home-manager.backupFileExtension = "backup";

  environment.variables.SHELL = "${pkgs.fish}/bin/fish";
  environment.shells = with pkgs; [
    bashInteractive
    zsh
    fish
  ];

  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

  # Allow unfree packages on desktops
  nixpkgs.config.allowUnfree = true;
}
