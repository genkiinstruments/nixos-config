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
    flake.modules.nixos.yggdrasil
  ];

  system.stateVersion = "23.05"; # Did you read the comment?

  facter.reportPath = ./facter.json;

  networking.interfaces.enp3s0.useDHCP = true;

  hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;

  boot.extraModprobeConfig = "options kvm_intel nested=1";

  boot.initrd.availableKernelModules = [
    # General
    "ahci" # SATA support
    "ata_piix"
    "nvme" # NVMe support
    "sd_mod"
    "sdhci_pci"
    "sr_mod"
    "usb_storage"
    "usbhid" # USB HID support
    "xhci_pci" # USB 3.0 support
  ];
  boot.kernelModules = [ "kvm-intel" ];

  # USB compatibility fixes for katla-frontpanel
  boot.kernelParams = [
    "usbcore.quirks=16c0:27dd:bki" # Disable autosuspend + reset quirks
    "usbcore.autosuspend=-1" # Disable global USB autosuspend
  ];
  # USB device access for katla-frontpanel
  services.udev.extraRules = ''
    # Genki katla-frontpanel USB device (both product IDs) - NixOS style
    SUBSYSTEM=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="27dd", MODE="0666", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="20b1", MODE="0666", TAG+="uaccess"
  '';
}
