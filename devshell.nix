{ pkgs, perSystem }:
pkgs.mkShellNoCC {
  packages = with pkgs; [
    git
    nixos-anywhere
    nh
    perSystem.deploy-rs.deploy-rs
  ];

  env.EDITOR = "nvim";
}
