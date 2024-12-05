{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./disko-config.nix
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
    inputs.self.modules.shared.default
    inputs.self.nixosModules.common
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "23.05"; # Did you read the comment?

  hardware.enableRedistributableFirmware = true;

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

  networking.useDHCP = lib.mkDefault true;

  nix.sshServe = {
    protocol = "ssh-ng";
    enable = true;
    write = true;
    keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG0Z5mbT3Zy/X+lLDeWVzBwMreSDBglSzDrq/TtbsVSY olafur@M3.local"
    ];
  };
  nix.settings.trusted-users = [ "nix-ssh" ];

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
        path = "/Users/genki/Desktop/my-secret";
        file = "${inputs.secrets}/my-secret.age";
        mode = "644";
        owner = "genki";
        group = "users";
      };
      atuin-key = {
        path = "/home/genki/.local/share/atuin/key";
        file = "${inputs.secrets}/atuin-key.age";
        mode = "644";
        owner = "genki";
        group = "users";
      };
      gdrn-github-runner-key.file = "${inputs.secrets}/gdrn-github-runner-key.age";
      gdrn-github-runner-cachixToken.file = "${inputs.secrets}/gdrn-github-runner-cachixToken.age";
    };
  };
  users.users.genki = {
    isNormalUser = true;
    shell = pkgs.fish;
    hashedPassword = "$y$j9T$m2uMTFs0f/KCLtDqCSuMO1$cjP9ZlnzZeIpH8Ibb8h2hbl//3hjgXEYVolfwG2vHg5";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keyFiles = [ ../../authorized_keys ];
  };
  users.users.root.openssh.authorizedKeys.keyFiles = [ ../../authorized_keys ];

  networking.hostName = "gdrn";
  networking.hostId = "deadbeef";

  home-manager.users.genki.imports = [ inputs.self.homeModules.default ];

  programs.ssh.startAgent = true;
}
