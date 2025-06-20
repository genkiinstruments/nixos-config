{ flake, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.programs.mvim = {
    enableSystemPackage = lib.mkEnableOption "mvim as a system package (standalone)";
  };

  config = lib.mkIf config.programs.mvim.enableSystemPackage {
    environment.systemPackages = [
      (import ../../packages/mvim.nix { inherit pkgs flake; })
    ];
  };
}
