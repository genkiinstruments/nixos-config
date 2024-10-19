{
  inputs,
  ...
}:
{
  imports = [
    ./disk-config.nix
    inputs.home-manager.nixosModules.home-manager
    inputs.disko.nixosModules.disko
    inputs.self.modules.shared.default
  ];

  disko.devices.disk.main.device = "/dev/disk/by-id/ata-SanDisk_SD8SN8U512G1002_175124804870";

  nixpkgs.hostPlatform = "x86_64-linux";

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

  networking.hostName = "kroli";
  networking.useDHCP = true;

  users.users.genki = {
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

  home-manager.users.genki.imports = [ inputs.self.homeModules.default ];

  programs.fish.enable = true; # Otherwise our shell won't be installed correctly
  services.openssh.enable = true;
  services.openssh.extraConfig = ''AllowAgentForwarding yes'';
  programs.ssh.startAgent = true;
  system.stateVersion = "23.05";
}
