{
  config,
  inputs,
  flake,
  perSystem,
  pkgs,
  ...
}:
let
  inherit (flake.lib) tailnet;
in
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
    flake.modules.shared.builders
    flake.nixosModules.common
    flake.nixosModules.ssh-serve
    ./disko-config.nix
  ];

  # Hardware optimizations
  boot = {
    # Kernel settings
    # [TODO]: Broken in nixpkgs (March 31, 2025 15:57, )
    # kernelPackages = pkgs.linuxPackages_latest; # Use latest kernel for AMD CPU optimizations

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

  programs.ssh.startAgent = true;

  services.tailscale.permitCertUid = "caddy";

  services.caddy = {
    enable = true;
    virtualHosts."${config.networking.hostName}.${tailnet}".extraConfig = ''
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
  nix.settings = {
    substituters = [ "https://genki.cachix.org" ];
    trusted-public-keys = [ "genki.cachix.org-1:5l+wAa4rDwhcd5Wm43eK4N73qJ6GIKmJQ87Nw/bRGfE=" ];
  };

  age.secrets.gdrn-cloudflared-tunnel.file = "${inputs.secrets}/gdrn-cloudflared-tunnel.age";

  users.users.root.initialHashedPassword = "$y$j9T$.Vjug8ygtDyb2DVz36qXb/$avXNbHp8sYL2jEY5IGEAr4xNXTra69sHxWzf9MEdYlD";

  services.cloudflared =
    let
      # [TODO]: Fix after upstream update (April 04, 2025 10:11, )

      patchedCloudflared = pkgs.cloudflared.override {
        buildGoModule = pkgs.buildGoModule.override {
          go = pkgs.buildPackages.go_1_23.overrideAttrs (old: {
            pname = "cloudflare-go";
            version = "1.22.5-devel-cf";

            src = pkgs.fetchFromGitHub {
              owner = "cloudflare";
              repo = "go";
              rev = "af19da5605ca11f85776ef7af3384a02a315a52b";
              hash = "sha256-6VT9CxlHkja+mdO1DeFoOTq7gjb3T5jcf2uf9TB/CkU=";
            };

            patches = map (
              patch:
              if (baseNameOf patch == "go_no_vendor_checks-1.23.patch") then
                ./exprs/go-no-vendor-1.22.patch
              else
                patch
            ) old.patches;
          });
        };
      };
    in
    {
      enable = true;
      package = patchedCloudflared.overrideAttrs { meta.broken = false; };
      tunnels."d148fd83-41dd-4e16-8ac8-4460c16b0258" = {
        credentialsFile = config.age.secrets.gdrn-cloudflared-tunnel.path;
        default = "http_status:404";
        ingress = {
          # Route requests to both the root domain and api subdomain to the fod-oracle service
          "fod-oracle.org" = "http://localhost:${toString config.services.fod-oracle.port}";
          "api.fod-oracle.org" = "http://localhost:${toString config.services.fod-oracle.port}";
          # Catch any subdomains or paths under the main domain
          "*.fod-oracle.org" = "http://localhost:${toString config.services.fod-oracle.port}";
        };
      };
    };

  # Fix TLS curve preferences by setting environment variables for cloudflared
  systemd.services.cloudflared.environment = {
    # Only use P-256 curve which is widely supported
    GODEBUG = "tls13=1,tlsrsakex=0,tlscurve=1";
    # Increase UDP buffer size to fix the buffer warning
    QUIC_GO_DISABLE_GSO = "1";
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
