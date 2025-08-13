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
    inputs.nixos-facter-modules.nixosModules.facter
    flake.modules.shared.default
    flake.modules.nixos.default
    ./disk-config.nix
  ];

  networking.hostName = "bubbi";

  system.stateVersion = "23.05"; # Did you read the comment?

  facter.reportPath = ./facter.json;

  users.users.root.initialHashedPassword = "$y$j9T$xA3OJK4WPx3Gu80.nTV6h/$DsBKf3OL11/d9bOAQmSVbgf2H2Ue4FAwhPLcatF0tX3";

  boot.extraModprobeConfig = "options kvm_intel nested=1";

  # USB compatibility fixes for katla-frontpanel
  boot.kernelParams = [
    "usbcore.quirks=16c0:27dd:bki" # Disable autosuspend + reset quirks
    "usbcore.autosuspend=-1" # Disable global USB autosuspend
  ];
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

  security.sudo.wheelNeedsPassword = false;
  # USB device access for katla-frontpanel
  services.udev.extraRules = ''
    # Genki katla-frontpanel USB device (both product IDs) - NixOS style
    SUBSYSTEM=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="27dd", MODE="0666", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="20b1", MODE="0666", TAG+="uaccess"
  '';
}
