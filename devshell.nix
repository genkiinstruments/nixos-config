{
  pkgs,
  perSystem,
}:
pkgs.mkShellNoCC {
  packages =
    with pkgs;
    [
      git
      nixos-anywhere
      nixos-rebuild
      home-manager
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      perSystem.nix-darwin.darwin-rebuild
    ];

  env = { };

  shellHook = ''export EDITOR=nvim'';
}
