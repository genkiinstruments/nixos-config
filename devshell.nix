{ pkgs }:
pkgs.mkShellNoCC {
  packages = with pkgs; [
    git
    nixos-anywhere
    nh
  ];

  env.EDITOR = "nvim";
}
