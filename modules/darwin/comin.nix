{
  inputs,
  flake,
  ...
}:
{
  imports = [
    inputs.comin.darwinModules.comin
    flake.modules.shared.comin
  ];
}
