{ pkgs, perSystem }:
pkgs.mkShellNoCC {
  packages = with pkgs; [
    git
    nixos-anywhere
    nh
    perSystem.colmena.colmena
  ];

  env.EDITOR = "nvim";
}
