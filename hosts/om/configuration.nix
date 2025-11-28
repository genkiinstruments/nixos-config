{
  inputs,
  flake,
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
  ];

  system.stateVersion = "23.05"; # Did you read the comment?

  facter.reportPath = ./facter.json;

  boot.extraModprobeConfig = "options kvm_intel nested=1";

  boot.initrd.availableKernelModules = [
    # General
    "ata_piix"
    "sd_mod"
    "sr_mod"
    "usb_storage"
    "sdhci_acpi"
    "nvme" # NVMe support
    "xhci_pci" # USB 3.0 support
    "ahci" # SATA support
    "usbhid" # USB HID support
  ];

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
