{ pkgs, perSystem }:
pkgs.mkShell {
  packages =
    with pkgs;
    [
      nixfmt-rfc-style
      git
      nixos-anywhere
      nixos-rebuild
      age
      age-plugin-yubikey
      age-plugin-fido2-hmac
      perSystem.self.deploy
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      perSystem.nix-darwin.darwin-rebuild
    ];

  env = { };

  shellHook = ''export EDITOR=nvim'';
}
