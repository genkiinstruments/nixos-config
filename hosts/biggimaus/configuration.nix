{
  inputs,
  flake,
  pkgs,
  ...
}:
{
  imports = [
    inputs.srvos.nixosModules.server
    inputs.srvos.nixosModules.mixins-systemd-boot
    inputs.srvos.nixosModules.mixins-terminfo
    inputs.srvos.nixosModules.mixins-nix-experimental
    inputs.srvos.nixosModules.mixins-trusted-nix-caches
    inputs.disko.nixosModules.disko
    flake.modules.shared.default
    flake.modules.shared.home-manager
    flake.nixosModules.common
    ./disko-config.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "23.05";

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];
    kernelModules = [ "kvm-intel" ];
  };

  networking.hostName = "biggimaus";
  networking.hostId = "deadbeef";
  networking.useDHCP = true;

  users.users.genki = {
    isNormalUser = true;
    shell = pkgs.fish;
    openssh.authorizedKeys.keyFiles = [ "${flake}/authorized_keys" ];
    extraGroups = [ "wheel" ];
  };

  users.users.root.openssh.authorizedKeys.keyFiles = [ "${flake}/authorized_keys" ];
}
