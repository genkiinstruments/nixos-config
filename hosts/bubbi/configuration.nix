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

  boot.extraModprobeConfig = ''
    options kvm_intel nested=1
    options xhci_hcd quirks=0x40000000
  '';

  # USB compatibility fixes for katla-frontpanel
  boot.kernelParams = [
    "usbcore.quirks=16c0:27dd:bk" # Disable autosuspend + reset resume quirk
    "usbcore.use_both_schemes=0" # Use old USB enumeration scheme
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
    SUBSYSTEM=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="27dd", MODE="0664", GROUP="users", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="20b1", MODE="0664", GROUP="users", TAG+="uaccess"
  '';
}
