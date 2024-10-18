{
  inputs,
  ...
}:
let
  user = "genki";
  userName = "Ólafur Bjarki Bogason";
  userEmail = "olafur@genkiinstruments.com";
in
{
  imports = [
    inputs.srvos.nixosModules.server
    inputs.srvos.nixosModules.mixins-systemd-boot
    inputs.srvos.nixosModules.mixins-terminfo
    inputs.srvos.nixosModules.mixins-nix-experimental
    inputs.srvos.nixosModules.mixins-trusted-nix-caches
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    ../../modules/shared
    ./disko-config.nix
  ];
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
  users.users.${user} = {
    isNormalUser = true;
    shell = "/run/current-system/sw/bin/fish";
    openssh.authorizedKeys.keyFiles = [ ../../authorized_keys ];
    extraGroups = [ "wheel" ];
  };
  users.users.root.openssh.authorizedKeys.keyFiles = [ ../../authorized_keys ];
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "backup";
  home-manager.users.${user} =
    { config, ... }:
    {
      imports = [
        inputs.nix-index-database.hmModules.nix-index
        inputs.catppuccin.homeManagerModules.catppuccin
        ../../modules/shared/home.nix
      ];
      catppuccin = {
        enable = true;
        flavor = "mocha";
      };
      programs.git = {
        inherit userEmail userName;
      };
      programs.atuin.settings.daemon.enabled = true;
    };
  programs.fish.enable = true; # Otherwise our shell won't be installed correctly
  services.tailscale.enable = true;
  system.stateVersion = "23.05";
}
