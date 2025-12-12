{
  inputs,
  flake,
  ...
}:
{
  imports = [
    inputs.srvos.nixosModules.server
    inputs.srvos.nixosModules.mixins-terminfo
    inputs.srvos.nixosModules.mixins-systemd-boot
    inputs.srvos.nixosModules.mixins-trusted-nix-caches
    inputs.disko.nixosModules.disko
    inputs.nixos-facter-modules.nixosModules.facter
    flake.modules.shared.default
    flake.modules.nixos.default
    flake.modules.nixos.comin
    flake.modules.nixos.katla-udev
    flake.modules.nixos.yggdrasil
    ./disk-config.nix
  ];

  system.stateVersion = "23.05";
  facter.reportPath = ./facter.json;
  boot.initrd.systemd.enable = true;
}
