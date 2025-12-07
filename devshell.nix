{ pkgs, perSystem }:
pkgs.mkShellNoCC {
  packages = with pkgs; [
    git
    nixos-anywhere
    nh
    perSystem.deploy-rs.deploy-rs
    perSystem.self.deploy-all
    perSystem.self.comin-all
  ];
  env.EDITOR = "mvim";
}
