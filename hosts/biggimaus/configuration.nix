{ inputs, ... }:
{
  imports = [
    inputs.srvos.nixosModules.server
    inputs.srvos.nixosModules.mixins-systemd-boot
    inputs.srvos.nixosModules.mixins-terminfo
    inputs.srvos.nixosModules.mixins-nix-experimental
    inputs.srvos.nixosModules.mixins-trusted-nix-caches
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    inputs.self.modules.shared.default
    ./disko-config.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  disko.devices.disk.main.device = "/dev/disk/by-id/nvme-eui.002538db21a8a97f";

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
    shell = "/run/current-system/sw/bin/fish";
    openssh.authorizedKeys.keyFiles = [ ../../authorized_keys ];
    extraGroups = [ "wheel" ];
  };

  users.users.root.openssh.authorizedKeys.keyFiles = [ ../../authorized_keys ];

  home-manager.users.genki.imports = [ inputs.self.homeModules.default ];
  home-manager.users.genki.programs.atuin.settings.daemon.enabled = true;

  programs.fish.enable = true; # Otherwise our shell won't be installed correctly
  system.stateVersion = "23.05";
}
