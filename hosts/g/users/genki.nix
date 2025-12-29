{
  flake,
  inputs,
  ...
}:
{
  imports = [
    inputs.niri.homeModules.niri
    flake.modules.home.default
    flake.modules.home.olafur
    flake.modules.home.niri
  ];
}
