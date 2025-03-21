{
  config,
  inputs,
  flake,
  perSystem,
  pkgs,
  ...
}:
{
  imports = [
    inputs.srvos.nixosModules.server
    inputs.srvos.nixosModules.mixins-systemd-boot
    inputs.srvos.nixosModules.mixins-terminfo
    inputs.srvos.nixosModules.mixins-trusted-nix-caches
    inputs.srvos.nixosModules.roles-github-actions-runner
    inputs.disko.nixosModules.disko
    inputs.agenix.nixosModules.default
    inputs.fod-oracle.nixosModules.default
    inputs.nixos-facter-modules.nixosModules.facter
    flake.modules.shared.default
    flake.nixosModules.common
    ./disko-config.nix
  ];

  # Hardware optimizations
  boot = {
    # Kernel settings
    kernelPackages = pkgs.linuxPackages_latest; # Use latest kernel for AMD CPU optimizations

    # Hardware-specific optimizations
    kernelParams = [
      # CPU optimizations
      "amd_pstate=active" # Enable AMD pstate driver for better power management
      "processor.max_cstate=5" # Limit C-states for better latency

      # I/O optimizations
      "elevator=none" # Use the multi-queue scheduler for NVMe
      "transparent_hugepage=madvise" # Set THP to madvise for server workloads

      # Memory optimizations
      "default_hugepagesz=2M" # Default huge page size
      "hugepagesz=1G" # Support for 1GB huge pages
    ];

    initrd.availableKernelModules = [
      "nvme" # NVMe support
      "xhci_pci" # USB 3.0 support
      "ahci" # SATA support
      "usbhid" # USB HID support
    ];
  };

  # NVMe and disk optimizations
  services.fstrim.enable = true; # Enable TRIM for SSDs
  services.fstrim.interval = "daily"; # Run TRIM daily

  # ZFS optimizations
  services.zfs = {
    autoScrub.enable = true;
    autoScrub.interval = "weekly";
    trim.enable = true;
  };

  system.stateVersion = "23.05"; # Did you read the comment?

  facter.reportPath = ./facter.json;

  # Optimized memory configuration for AMD Ryzen
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 90;
  };

  # CPU optimization settings for AMD processors
  hardware.cpu.amd.updateMicrocode = true;

  # Enable specific performance governors
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };

  nix.sshServe = {
    protocol = "ssh-ng";
    enable = true;
    write = true;
    # Nix daemon needs to be able to authenticate non-interactively.
    keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJMSR/8/YBvhetwK3qcgnz39xnk27Oq1mHLaEpFRiXhR olafur@M3.local"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEgZsVoqTNrbGtewP2+mEBSXQuiEEWcGuRyp0VtyQ9NR genki@v1"
    ];
  };
  nix.settings.trusted-users = [ "nix-ssh" ];

  programs.ssh.startAgent = true;

  services.tailscale.permitCertUid = "caddy";

  services.caddy = {
    enable = true;
    virtualHosts."gdrn.tail01dbd.ts.net".extraConfig = ''
      root * ${perSystem.genki-www.default}
      file_server
    '';
  };

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

  age.secrets.gdrn-cloudflared-tunnel.file = "${inputs.secrets}/gdrn-cloudflared-tunnel.age";
  age.secrets.gdrn-cloudflared-tunnel.owner = "cloudflared";
  age.secrets.gdrn-cloudflared-tunnel.group = "cloudflared";

  users.users.root.initialHashedPassword = "$y$j9T$.Vjug8ygtDyb2DVz36qXb/$avXNbHp8sYL2jEY5IGEAr4xNXTra69sHxWzf9MEdYlD";

  services.cloudflared.enable = true;
  services.cloudflared.tunnels."d148fd83-41dd-4e16-8ac8-4460c16b0258" = {
    credentialsFile = config.age.secrets.gdrn-cloudflared-tunnel.path;
    default = "http_status:404";
    ingress."api.fod-oracle.org" = "http://localhost:${toString config.services.fod-oracle.port}";
  };

  networking.hostName = "gdrn";

  # Enable the FOD Oracle API service
  services.fod-oracle = {
    enable = true;
    port = 8081;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    # Tools for database management and debugging
    sqlite
    curl
    jq
  ];
}
