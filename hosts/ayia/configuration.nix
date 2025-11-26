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

  system.stateVersion = "23.05"; # Did you read the comment?

  facter.reportPath = ./facter.json;

  boot.extraModprobeConfig = "options kvm_intel nested=1";
  boot.initrd.availableKernelModules = [
    # General
    "ahci"
    "ata_piix"
    "sd_mod"
    "sr_mod"
    "usb_storage"
    "ehci_hcd"
    "uhci_hcd"
    # MMC
    "mmc_block"
    "sdhci_acpi"
  ];

  services.udev.extraRules = ''
    # Genki katla-frontpanel USB device (both product IDs) - NixOS style
    SUBSYSTEM=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="27dd", MODE="0664", GROUP="users", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="20b1", MODE="0664", GROUP="users", TAG+="uaccess"
  '';
}
