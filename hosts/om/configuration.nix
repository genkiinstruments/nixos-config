{
  inputs,
  flake,
  config,
  ...
}:
{
  imports = [
    inputs.srvos.nixosModules.server
    inputs.srvos.nixosModules.mixins-systemd-boot
    inputs.srvos.nixosModules.mixins-terminfo
    inputs.srvos.nixosModules.mixins-trusted-nix-caches
    inputs.disko.nixosModules.disko
    ./disk-config.nix
    inputs.nixos-facter-modules.nixosModules.facter
    flake.modules.shared.default
    flake.modules.nixos.default
    flake.modules.nixos.ssh-serve
    flake.modules.nixos.yggdrasil
    flake.modules.nixos.katla-udev
  ];

  system.stateVersion = "23.05";
  facter.reportPath = ./facter.json;

  networking.useDHCP = false;
  networking.interfaces.enp3s0.useDHCP = true;
  networking.firewall.trustedInterfaces = [ "enp3s0" ];

  hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
}
