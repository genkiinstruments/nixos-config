{
  config,
  inputs,
  flake,
  perSystem,
  pkgs,
  ...
}:
let
  mkWebshippyStripeSyncSecret = name: {
    file = "${inputs.secrets}/${name}.age";
    owner = config.services.stripe-webshippy-sync.user;
    group = config.services.stripe-webshippy-sync.group;
  };
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
    inputs.stripe-webshippy-sync.nixosModules.default
    flake.modules.shared.default
    flake.modules.shared.builders
    flake.modules.shared.home-manager
    flake.modules.nixos.default
    flake.modules.nixos.ssh-serve
    flake.modules.nixos.comin
    ./disko-config.nix
  ];

  networking.hostName = "gdrn";

  networking.firewall.trustedInterfaces = [ "enp1s0" ];
  networking.interfaces.enp1s0.useDHCP = true;

  # Enable NAT for containers to access internet
  networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-+" ];
    externalInterface = "enp1s0";
  };

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

  age.secrets.genki-is-cloudflare-api-token.file = "${inputs.secrets}/genki-is-cloudflare-api-token.age";
  age.secrets.genki-is-cloudflare-api-token.owner = "caddy";
  age.secrets.genki-is-cloudflare-api-token.group = "caddy";
  age.secrets.genki-is-cloudflare-api-token.mode = "0400";

  services.uptime-kuma.enable = true;
  caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.1" ];
      hash = "sha256-2D7dnG50CwtCho+U+iHmSj2w14zllQXPjmTHr6lJZ/A=";
    };

    virtualHosts."uptime-kuma.tail01dbd.ts.net".extraConfig = ''
      tls {
          dns cloudflare {env.CLOUDFLARE_API_TOKEN}
      }
      reverse_proxy http://localhost:3001
    '';
    virtualHosts."uptime-kuma.genki.is".extraConfig = ''
      tls {
          dns cloudflare {env.CLOUDFLARE_API_TOKEN}
      }
      reverse_proxy http://localhost:3001
    '';
  };
  systemd.services.caddy.serviceConfig.EnvironmentFile =
    config.age.secrets.genki-is-cloudflare-api-token.path;

  tailscale.permitCertUid = "caddy";

  # Stripe-Webshippy-Sync secrets
  age.secrets.stripe-secret-key = mkWebshippyStripeSyncSecret "stripe-secret-key";
  age.secrets.stripe-webhook-secret = mkWebshippyStripeSyncSecret "stripe-webhook-secret";
  age.secrets.webshippy-api-key = mkWebshippyStripeSyncSecret "webshippy-api-key";
  age.secrets.r2-access-key-id = mkWebshippyStripeSyncSecret "r2-access-key-id";
  age.secrets.r2-secret-access-key = mkWebshippyStripeSyncSecret "r2-secret-access-key";
  age.secrets.r2-endpoint-url = mkWebshippyStripeSyncSecret "r2-endpoint-url";
  age.secrets.r2-bucket-name = mkWebshippyStripeSyncSecret "r2-bucket-name";
  age.secrets.r2-public-url = mkWebshippyStripeSyncSecret "r2-public-url";

  # Stripe-Webshippy-Sync service configuration
  services.stripe-webshippy-sync = {
    enable = true;

    stripeSecretKeyFile = config.age.secrets.stripe-secret-key.path;
    stripeWebhookSecretFile = config.age.secrets.stripe-webhook-secret.path;
    webshippyApiKeyFile = config.age.secrets.webshippy-api-key.path;

    s3 = {
      accessKeyIdFile = config.age.secrets.r2-access-key-id.path;
      secretAccessKeyFile = config.age.secrets.r2-secret-access-key.path;
      endpointUrlFile = config.age.secrets.r2-endpoint-url.path;
      bucketNameFile = config.age.secrets.r2-bucket-name.path;
      publicUrlFile = config.age.secrets.r2-public-url.path;
    };
  };

  # Tailscale funnel for stripe-webshippy-sync webhook
  systemd.services.tailscale-funnel-stripe-webhook = {
    description = "Tailscale funnel for Stripe webhook";
    wantedBy = [ "multi-user.target" ];
    after = [
      "tailscaled.service"
      "stripe-webshippy-sync.service"
    ];
    wants = [
      "tailscaled.service"
      "stripe-webshippy-sync.service"
    ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.tailscale}/bin/tailscale funnel --https=443 ${toString config.services.stripe-webshippy-sync.port}";
      ExecStop = "${pkgs.tailscale}/bin/tailscale funnel --https=443 off";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
  users.users.root.initialHashedPassword = "$y$j9T$.Vjug8ygtDyb2DVz36qXb/$avXNbHp8sYL2jEY5IGEAr4xNXTra69sHxWzf9MEdYlD";

  services.cloudflared = {
    enable = true;
    tunnels."d148fd83-41dd-4e16-8ac8-4460c16b0258" = {
      credentialsFile = config.age.secrets.gdrn-cloudflared-tunnel.path;
      default = "http_status:404";
      ingress = {
        "fod-oracle.org" = "http://localhost:5173";
        # API endpoints go to the fod-oracle service
        "api.fod-oracle.org" = "http://localhost:${toString config.services.fod-oracle.port}";
      };
    };
  };

  # Use static file server instead of Caddy to avoid certificate warnings
  systemd.services.static-file-server = {
    description = "Simple static file server for docs";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.python3}/bin/python3 -m http.server 5173 --directory ${perSystem.fod-oracle.docs}/share/doc/docs";
      Restart = "always";
      RestartSec = "5";
      DynamicUser = true;
    };
  };

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
    cmatrix

    # Tools for clipboard support
    xclip
    wl-clipboard
  ];

  # Don't require password for sudo
  security.sudo.wheelNeedsPassword = false;

  users.mutableUsers = false;
  # We are using zfs: https://github.com/atuinsh/atuin/issues/952#issuecomment-2199964530
  home-manager.users.olafur.programs.atuin.daemon.enable = true;
  users.users.olafur = {
    isNormalUser = true;
    description = "olafur";
    shell = pkgs.fish;
    hashedPassword = "$6$UIOsLjI24UeaovvG$SVVrXdpnepj/w1jhmYNdpPpmcgkcXsMBcAkqrcIL5yCCYDAkc/8kblyzuBLyK6PnJqR1JxZ7XtlWyCJwWhGrw.";
    extraGroups = [
      "networkmanager"
      "wheel"
      "plugdev"
      "dialout"
      "video"
      "inputs"
    ];
    openssh.authorizedKeys.keyFiles = [ "${flake}/authorized_keys" ];
  };
  nix.settings.trusted-users = [ "olafur" ];
}
