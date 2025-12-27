{
  flake,
  ...
}:
{
  imports = [
    flake.modules.home.default
    flake.modules.home.olafur
  ];
}
