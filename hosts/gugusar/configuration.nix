{
  inputs,
  ...
}:
{
  imports = [
    inputs.srvos.nixosModules.server
    inputs.srvos.nixosModules.mixins-systemd-boot
    inputs.srvos.nixosModules.mixins-terminfo
    inputs.srvos.nixosModules.mixins-nix-experimental
    inputs.srvos.nixosModules.mixins-trusted-nix-caches
    inputs.home-manager.nixosModules.home-manager
    inputs.disko.nixosModules.disko
    inputs.self.modules.shared.default
    ./disk-config.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  disko.devices.disk.main.device = "/dev/disk/by-id/ata-TOSHIBA_KSG60ZMV256G_M.2_2280_256GB_583B83NWK5SP";

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
