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
  ];

  # Run GC at 3am to avoid blocking builds
  nix.gc = {
    automatic = true;
    dates = "03:00";
    options = "--delete-older-than 7d";
  };

  system.stateVersion = "25.11"; # Did you read the comment?
  facter.reportPath = ./facter.json;

  # the issue is that logind allocates 25% of your system memory to /run rather than more by default, we need to increase that so that builds don't fail
  services.logind.settings.Login.RuntimeDirectorySize = "75%";
  boot.runSize = "75%";

  hardware.asahi = {
    enable = true;
    extractPeripheralFirmware = true;
    peripheralFirmwareDirectory = ./firmware;
  };
  hardware.graphics.enable32Bit = lib.mkForce false;

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
      "sd_mod"
      "sdhci_pci"
      "usb_storage"
      "usbhid"
      "xhci_pci"
    ];
    initrd.kernelModules = [
      "usbhid"
      "dm-snapshot"
    ];
  };
  # Disable wireless networking entirely
  networking.wireless.enable = false;
  networking.wireless.iwd.enable = false;
  boot.extraModprobeConfig = ''blacklist brcmfmac'';

  # Enable wired networking for built-in ethernet and USB-C adapter
  networking.useDHCP = false;
  networking.interfaces.enu1.useDHCP = true;
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
  swapDevices = [ ];
}
