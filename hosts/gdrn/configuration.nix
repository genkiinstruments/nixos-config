{
  config,
  inputs,
  flake,
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
    inputs.srvos.nixosModules.roles-nix-remote-builder
    inputs.disko.nixosModules.disko
    inputs.agenix.nixosModules.default
    inputs.nixos-facter-modules.nixosModules.facter
    inputs.stripe-webshippy-sync.nixosModules.default
    flake.modules.shared.default
    flake.modules.shared.home-manager
    flake.modules.nixos.default
    flake.modules.nixos.zram-swap
    flake.modules.nixos.ssh-serve
    flake.modules.nixos.monitoring
    flake.modules.nixos.olafur
    ./disko-config.nix
  ];

  networking.firewall.trustedInterfaces = [ "enp1s0" ];
  networking.interfaces.enp1s0.useDHCP = true;

  roles.nix-remote-builder.schedulerPublicKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBBtnJ1eS+mI4EASAWk7NXin5Hln0ylYUPHe2ovQAa8G root@x"
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

  services.uptime-kuma.enable = true;
  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.1" ];
      hash = "sha256-AcWko5513hO8I0lvbCLqVbM1eWegAhoM0J0qXoWL/vI=";
    };

    virtualHosts."uptime-kuma.genki.is".extraConfig = ''
      tls {
          dns cloudflare {env.CLOUDFLARE_API_TOKEN}
      }
      reverse_proxy http://localhost:3001
    '';
  };

  # Enable monitoring stack
  services.monitoring = {
    enable = true;
    domain = "genki.is";
  };
  systemd.services.caddy.serviceConfig.EnvironmentFile =
    config.age.secrets.genki-is-cloudflare-api-token.path;

  services.tailscale.permitCertUid = "caddy";
  age.secrets =
    let
      mkWebshippyStripeSyncSecret = name: {
        file = "${inputs.secrets}/${name}.age";
        owner = config.services.stripe-webshippy-sync.user;
        group = config.services.stripe-webshippy-sync.group;
      };
    in
    {
      gdrn-github-runner-key.file = "${inputs.secrets}/gdrn-github-runner-key.age";
      gdrn-github-runner-cachixToken.file = "${inputs.secrets}/gdrn-github-runner-cachixToken.age";

      gdrn-cloudflared-tunnel.file = "${inputs.secrets}/gdrn-cloudflared-tunnel.age";

      stripe-webhook-genki-is-cloudflare-tunnel-secret.file = "${inputs.secrets}/stripe-webhook-genki-is-cloudflare-tunnel-secret.age";

      genki-is-cloudflare-api-token.file = "${inputs.secrets}/genki-is-cloudflare-api-token.age";
      genki-is-cloudflare-api-token.owner = "caddy";
      genki-is-cloudflare-api-token.group = "caddy";
      genki-is-cloudflare-api-token.mode = "0400";

      # Stripe-Webshippy-Sync secrets
      stripe-secret-key = mkWebshippyStripeSyncSecret "stripe-secret-key";
      stripe-webhook-secret = mkWebshippyStripeSyncSecret "stripe-webhook-secret";
      webshippy-api-key = mkWebshippyStripeSyncSecret "webshippy-api-key";
      r2-access-key-id = mkWebshippyStripeSyncSecret "r2-access-key-id";
      r2-secret-access-key = mkWebshippyStripeSyncSecret "r2-secret-access-key";
      r2-endpoint-url = mkWebshippyStripeSyncSecret "r2-endpoint-url";
      r2-bucket-name = mkWebshippyStripeSyncSecret "r2-bucket-name";
      r2-public-url = mkWebshippyStripeSyncSecret "r2-public-url";
    };

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

  # Cloudflare tunnel for Stripe webhook
  services.cloudflared = {
    enable = true;
    tunnels = {
      "76c2b04c-4171-48fb-92a3-1312b9cc1b98" = {
        credentialsFile = config.age.secrets.stripe-webhook-genki-is-cloudflare-tunnel-secret.path;
        ingress."stripe-webhook.genki.is" =
          "http://localhost:${toString config.services.stripe-webshippy-sync.port}";
        default = "http_status:404";
      };
    };
  };

  # We are using zfs: https://github.com/atuinsh/atuin/issues/952#issuecomment-2199964530
  home-manager.users.olafur.programs.atuin.daemon.enable = true;
}
