{ pkgs, perSystem }:
pkgs.mkShellNoCC {
  packages = with pkgs; [
    git
    nixos-anywhere
    nh
    perSystem.self.all
  ];
  env.EDITOR = "mvim";
}
