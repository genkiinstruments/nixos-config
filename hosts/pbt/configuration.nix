{
  inputs,
  flake,
  lib,
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [
    inputs.srvos.nixosModules.desktop
    inputs.srvos.nixosModules.mixins-terminfo
    inputs.srvos.nixosModules.mixins-systemd-boot
    inputs.agenix.nixosModules.default
    flake.modules.shared.default
    flake.nixosModules.common
    flake.nixosModules.ssh-serve
    ./apple-silicon-support
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  nixpkgs.hostPlatform = "aarch64-linux";
  networking.hostName = "pbt";
  system.stateVersion = "25.05"; # Did you read the comment?

  environment.systemPackages = [
    # openssh # needed for fido2 support
    # openssh is not available on aarch64-linux
    pkgs.hello
  ];

  hardware.asahi = {
    enable = true;
    extractPeripheralFirmware = true;
    peripheralFirmwareDirectory = ./firmware;
    withRust = true;
    setupAsahiSound = true;
    useExperimentalGPUDriver = true;
    experimentalGPUInstallMode = "replace";
  };
  hardware.graphics.enable32Bit = lib.mkForce false;
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    # This refers to the uncompressed size, actual memory usage will be lower.
    memoryPercent = 50;
  };

  boot = {
    # https://rdx.overdevs.com/comments.html?url=https://www.reddit.com/r/AsahiLinux/comments/1gy0t86/psa_transitioning_from_zramswap_to_zswap/
    kernelParams = [
      "zswap.zpool=zsmalloc"
    ];
    binfmt.emulatedSystems = [ "x86_64-linux" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = lib.mkForce false;
    };
    initrd.availableKernelModules = [
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];
    initrd.kernelModules = [
      "usbhid"
      "dm-snapshot"
    ];
  };
  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = true;
  };

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
