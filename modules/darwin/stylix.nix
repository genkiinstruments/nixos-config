{ inputs, flake, ... }:
{
  imports = [
    inputs.stylix.darwinModules.stylix
    flake.modules.shared.stylix
  ];
}
