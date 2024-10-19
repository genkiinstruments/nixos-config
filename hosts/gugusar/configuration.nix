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
    inputs.home-manager.nixosModules.home-manager
    inputs.disko.nixosModules.disko
    inputs.self.modules.shared.default
  ];
  nixpkgs.hostPlatform = "x86_64-linux";
  disko.devices = {
    disk = {
      main = {
        device = "/dev/disk/by-id/ata-TOSHIBA_KSG60ZMV256G_M.2_2280_256GB_583B83NWK5SP";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02"; # for grub MBR
            };
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "usb_storage"
      "sd_mod"
    ];
    kernelModules = [ "kvm-intel" ];
  };
  networking.hostName = "gugusar";
  networking.useDHCP = true;
  users.users.${user} = {
    isNormalUser = true;
    shell = "/run/current-system/sw/bin/fish";
    openssh.authorizedKeys.keyFiles = [ ../../authorized_keys ];
    extraGroups = [ "wheel" ];
    hashedPassword = "";
  };
  users.users.root.openssh.authorizedKeys.keyFiles = [ ../../authorized_keys ];
  users.users.root.hashedPassword = "";
  security.sudo.execWheelOnly = true;
  security.sudo.wheelNeedsPassword = false;
  security.sudo.extraConfig = ''Defaults lecture = never'';
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "backup";
  home-manager.users.${user} =
    { config, ... }:
    {
      imports = [
        inputs.nix-index-database.hmModules.nix-index
        inputs.catppuccin.homeManagerModules.catppuccin
        inputs.self.homeModules.default
      ];
      catppuccin = {
        enable = true;
        flavor = "mocha";
      };
      programs.git = {
        inherit userEmail userName;
      };
    };
  programs.fish.enable = true; # Otherwise our shell won't be installed correctly
  services.tailscale.enable = true;
  services.openssh.enable = true;
  services.openssh.extraConfig = ''AllowAgentForwarding yes'';
  programs.ssh.startAgent = true;
  system.stateVersion = "23.05";
}
