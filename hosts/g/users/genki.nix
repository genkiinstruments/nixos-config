{
  flake,
  ...
}:
{
  imports = [
    flake.modules.home.default
    flake.modules.home.olafur
    flake.modules.home.niri
  ];
}
