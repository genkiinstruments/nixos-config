{
  pkgs,
  flake,
  lib,
  ...
}:
{
  imports = [ flake.modules.home.default ];

  # NOTE: Use this to add packages available everywhere on your system
  home.packages = with pkgs; [
    zed-editor
  ];
  programs.git = {
    userEmail = lib.mkForce "daniel@genkiinstruments.com";
    userName = lib.mkForce "dingari";
    extraConfig.github.user = lib.mkForce "dingari";
  };
}
