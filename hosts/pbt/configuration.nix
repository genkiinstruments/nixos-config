{
  inputs,
  flake,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    inputs.srvos.nixosModules.server
    inputs.srvos.nixosModules.roles-nix-remote-builder
    inputs.srvos.nixosModules.mixins-terminfo
    inputs.srvos.nixosModules.mixins-systemd-boot
    inputs.nixos-facter-modules.nixosModules.facter
    inputs.agenix.nixosModules.default
    flake.modules.shared.default
    flake.modules.shared.systemd-exporter
    flake.modules.nixos.default
    flake.modules.nixos.zram-swap
    flake.modules.nixos.ssh-serve
    ./apple-silicon-support
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  system.stateVersion = "25.05"; # Did you read the comment?
  facter.reportPath = ./facter.json;

  roles.nix-remote-builder.schedulerPublicKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBBtnJ1eS+mI4EASAWk7NXin5Hln0ylYUPHe2ovQAa8G root@x"
  ];

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

  # Disable WiFi module entirely
  boot.extraModprobeConfig = ''blacklist brcmfmac'';

  boot = {
    # https://rdx.overdevs.com/comments.html?url=https://www.reddit.com/r/AsahiLinux/comments/1gy0t86/psa_transitioning_from_zramswap_to_zswap/
    kernelParams = [
      "zswap.zpool=zsmalloc"
      # Disable WiFi to prevent issues
      "module_blacklist=brcmfmac"
    ];
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
  # Disable wireless networking entirely
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
