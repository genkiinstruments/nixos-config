{ inputs, flake, ... }:
{
  imports = [
    inputs.stylix.nixosModules.stylix
    flake.modules.shared.stylix
  ];
}
