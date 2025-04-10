{
  flake,
  inputs,
  config,
  pkgs,
  ...
}:
{
  imports = [
    flake.homeModules.default
    flake.homeModules.nvim
  ];

  # Configure SSH for clipboard sharing
  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host g
        SetEnv TERM=xterm-256color
    '';
  };

}
