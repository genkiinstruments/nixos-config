{
  lib,
  config,
  inputs,
  ...
}:
{
  imports = [
    ./disko-config.nix
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

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 90;
  };

  nix.sshServe = {
    protocol = "ssh-ng";
    enable = true;
    write = true;
    # For Nix remote builds, the SSH authentication needs to be non-interactive and not dependent on ssh-agent, since the Nix daemon needs to be able to authenticate automatically.
    keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJMSR/8/YBvhetwK3qcgnz39xnk27Oq1mHLaEpFRiXhR olafur@M3.local"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEgZsVoqTNrbGtewP2+mEBSXQuiEEWcGuRyp0VtyQ9NR genki@v1"
    ];
  };
  nix.settings.trusted-users = [
    "nix-ssh"
    "@wheel"
  ];

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
  age.secrets.gdrn-github-runner-key.file = "${inputs.secrets}/gdrn-github-runner-key.age";
  age.secrets.gdrn-github-runner-cachixToken.file = "${inputs.secrets}/gdrn-github-runner-cachixToken.age";

  users.users.root.openssh.authorizedKeys.keyFiles = [ ../../authorized_keys ];
  users.users.root.initialHashedPassword = "$y$j9T$.Vjug8ygtDyb2DVz36qXb/$avXNbHp8sYL2jEY5IGEAr4xNXTra69sHxWzf9MEdYlD";

  networking.hostName = "gdrn";
  networking.hostId = "deadbeef";

  programs.ssh.startAgent = true;
}
