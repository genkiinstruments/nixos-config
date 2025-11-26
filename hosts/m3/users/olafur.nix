{
  flake,
  ...
}:
{
  imports = [
    flake.modules.home.default
    flake.modules.home.olafur
  ];

  home.sessionVariables.MVIM_CONFIG_SOURCE = "/private/etc/nixos-config/home/nvim";
}
