{ pkgs, perSystem }:
pkgs.mkShellNoCC {
  packages = with pkgs; [
    git
    nixos-anywhere
    nh
    perSystem.self.all
    perSystem.self.ni
  ];
  env.EDITOR = "nvim";
}
