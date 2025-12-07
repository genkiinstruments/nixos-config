{
  inputs,
  flake,
  lib,
  ...
}:
{
  imports = [
    inputs.srvos.nixosModules.server
    inputs.srvos.nixosModules.mixins-terminfo
    inputs.srvos.nixosModules.mixins-systemd-boot
    inputs.nixos-facter-modules.nixosModules.facter
    inputs.agenix.nixosModules.default
    flake.modules.shared.default
    flake.modules.nixos.default
    flake.modules.nixos.zram-swap
    flake.modules.nixos.ssh-serve
    inputs.nixos-apple-silicon.nixosModules.apple-silicon-support
    flake.modules.nixos.comin
    flake.modules.shared.comin-check-buildbot
  ];

  system.stateVersion = "25.11";
  facter.reportPath = ./facter.json;

  services.logind.settings.Login.RuntimeDirectorySize = "75%";
  boot.runSize = "75%";

  nix.gc = {
    automatic = true;
    dates = "Sun 03:00"; # Weekly instead of daily
    options = "--delete-older-than 30d"; # Keep for 30 days
  };
  nix.optimise = {
    automatic = true;
    dates = "monthly"; # Less frequent
  };

  hardware.asahi = {
    enable = true;
    extractPeripheralFirmware = true;
    peripheralFirmwareDirectory = ./firmware;
  };
  hardware.graphics.enable32Bit = lib.mkForce false;

  boot = {
    extraModprobeConfig = "blacklist brcmfmac";
    kernelParams = [ "zswap.zpool=zsmalloc" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = lib.mkForce false;
    };
  };

  networking.useDHCP = false;
  networking.interfaces.end0.useDHCP = true;

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/7468e770-e65a-418e-ab99-22daab5274b9";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/4510-16F0";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };
}
