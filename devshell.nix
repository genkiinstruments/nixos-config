{ pkgs }:
pkgs.mkShellNoCC {
  packages = with pkgs; [
    git
    nixos-anywhere
    nh
    deploy-rs
  ];

  env.EDITOR = "nvim";
}
