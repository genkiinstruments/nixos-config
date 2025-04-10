{
  flake,
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
  };

}
