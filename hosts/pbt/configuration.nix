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
    flake.modules.nixos.comin
    flake.modules.shared.comin-check-buildbot
    ./apple-silicon-support
  ];

  system.stateVersion = "25.05";
  facter.reportPath = ./facter.json;

  # the issue is that logind allocates 25% of your system memory to /run rather than more by default, we need to increase that so that builds don't fail
  services.logind.settings.Login.RuntimeDirectorySize = "50%";
  boot.runSize = "50%";

  hardware.asahi = {
    enable = true;
    extractPeripheralFirmware = true;
    peripheralFirmwareDirectory = ./firmware;
    withRust = false;
    setupAsahiSound = true;
    useExperimentalGPUDriver = false;
    experimentalGPUInstallMode = "replace";
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

  networking.wireless.enable = false;
  networking.wireless.iwd.enable = false;

  # Enable wired networking for built-in ethernet and USB-C adapter
  networking.useDHCP = false;
  networking.interfaces.enu1.useDHCP = true;
  networking.interfaces.end0.useDHCP = true;

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/91812e0b-248e-46f7-b104-95af0d3e0801";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/FD3B-180E";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };
}
