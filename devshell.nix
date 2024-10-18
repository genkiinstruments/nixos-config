{ pkgs, perSystem }:
pkgs.mkShell {
  # Add build dependencies
  packages = with pkgs; [
    bashInteractive
    git
    nixos-anywhere
    age
    age-plugin-yubikey
    age-plugin-fido2-hmac
    # perSystem.nix-darwin.darwin-rebuild
  ];

  # Add environment variables
  env = { };

  # Load custom bash code
  shellHook = ''export EDITOR=nvim'';
}
