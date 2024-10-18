{
  lib,
  pkgs,
  config,
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
    inputs.srvos.nixosModules.server
    inputs.srvos.nixosModules.mixins-systemd-boot
    inputs.srvos.nixosModules.mixins-terminfo
    inputs.srvos.nixosModules.mixins-nix-experimental
    inputs.srvos.nixosModules.mixins-trusted-nix-caches
    inputs.srvos.nixosModules.roles-github-actions-runner
    inputs.disko.nixosModules.disko
    inputs.agenix.nixosModules.default
    inputs.nixos-hardware.nixosModules.common-cpu-amd-raphael-igpu
    ./disko-config.nix
    ../../modules/shared
  ];
  nixpkgs.hostPlatform = "x86_64-linux";
  disko.devices.disk.main.device = "/dev/disk/by-id/nvme-eui.002538b931a6cbb0";

  hardware.enableRedistributableFirmware = true;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usb_storage"
    "usbhid"
    "sd_mod"
    "sr_mod"
  ];
  boot.kernelModules = [ "kvm-amd" ];

  nix.gc.automatic = true;
  nix.gc.dates = "*:45";
  nix.gc.options = ''--max-freed "$((128 * 1024**3 - 1024 * $(df -P -k /nix/store | tail -n 1 | ${pkgs.gawk}/bin/awk '{ print $4 }')))"'';

  networking.networkmanager.enable = true;
  networking.useDHCP = lib.mkDefault true;

  virtualisation.docker.enable = true;
  virtualisation.multipass.enable = true;

  # Enable tailscale. We manually authenticate when we want with "sudo tailscale up". 
  services.tailscale.enable = true;

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  fonts.enableDefaultPackages = true;
  fonts.fontDir.enable = true;
  fonts.packages = [ (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; }) ];

  system.stateVersion = "23.05"; # Did you read the comment?
  roles.github-actions-runner = {
    url = "https://github.com/genkiinstruments";
    count = 4;
    name = "gdrn-github-runner";
    githubApp = {
      id = "1003596";
      login = "genkiinstruments";
      privateKeyFile = config.age.secrets.gdrn-github-runner-key.path;
    };
    cachix.cacheName = "genki";
    cachix.tokenFile = config.age.secrets.gdrn-github-runner-cachixToken.path;
  };
  age = {
    secrets = {
      my-secret = {
        symlink = true;
        path = "/Users/${user}/Desktop/my-secret";
        file = "${inputs.secrets}/my-secret.age";
        mode = "644";
        owner = "${user}";
        group = "users";
      };
      atuin-key = {
        symlink = true;
        path = "/home/${user}/.local/share/atuin/key";
        file = "${inputs.secrets}/atuin-key.age";
        mode = "644";
        owner = "${user}";
        group = "users";
      };
      gdrn-github-runner-key = {
        file = "${inputs.secrets}/gdrn-github-runner-key.age";
      };
      gdrn-github-runner-cachixToken = {
        file = "${inputs.secrets}/gdrn-github-runner-cachixToken.age";
      };
    };
  };
  users.users.${user} = {
    isNormalUser = true;
    shell = "/run/current-system/sw/bin/fish";
    description = "${userName}";
    hashedPassword = "$y$j9T$m2uMTFs0f/KCLtDqCSuMO1$cjP9ZlnzZeIpH8Ibb8h2hbl//3hjgXEYVolfwG2vHg5";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    openssh.authorizedKeys.keyFiles = [ ../../authorized_keys ];
  };
  users.users.root.openssh.authorizedKeys.keyFiles = [ ../../authorized_keys ];
  networking.hostName = "gdrn";
  networking.hostId = "deadbeef";
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
    };
  programs.fish.enable = true;
  services.openssh.extraConfig = ''AllowAgentForwarding yes'';
  programs.ssh.startAgent = true;
}
