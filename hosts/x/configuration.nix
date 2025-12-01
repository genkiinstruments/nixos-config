{
  inputs,
  flake,
  config,
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
    inputs.nixos-facter-modules.nixosModules.facter
    inputs.buildbot-nix.nixosModules.buildbot-master
    inputs.buildbot-nix.nixosModules.buildbot-worker
    flake.modules.shared.default
    flake.modules.shared.builders
    flake.modules.shared.home-manager
    flake.modules.nixos.default
    flake.modules.nixos.zram-swap
    flake.modules.nixos.olafur
    flake.modules.nixos.ssh-serve
    ./disko.nix
  ];

  genki.builders.builders = [
    {
      hostName = "m2";
      system = "aarch64-linux";
      maxJobs = 15;
    }
    {
      hostName = "gdrn";
      system = "x86_64-linux";
      maxJobs = 13;
    }
    {
      hostName = "pbt";
      system = "aarch64-linux";
      maxJobs = 3;
    }
    {
      hostName = "gkr";
      system = "aarch64-darwin";
      maxJobs = 3;
    }
    {
      hostName = "om";
      system = "x86_64-linux";
      maxJobs = 8;
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
        "cm5-io-board"
      ];
    }
  ];

  networking.firewall.trustedInterfaces = [
    "enp5s0"
    "eno1"
  ];
  networking.interfaces.enp5s0.useDHCP = true;
  networking.interfaces.eno1.useDHCP = true;

  services.cloudflared = {
    enable = true;
    tunnels = {
      "9c376bb1-4ca6-49d7-8c36-93908b752ae8" = {
        credentialsFile = config.age.secrets.x-cloudflare-tunnel-secret.path;
        ingress = {
          # Point to nginx (buildbot-nix configures nginx on port 80)
          "buildbot.genki.is" = "http://localhost:80";
        };
        default = "http_status:404";
      };
    };
  };

  # Ensure PostgreSQL and network are ready before buildbot-master starts
  systemd.services.buildbot-master = {
    wants = [
      "postgresql.service"
      "network-online.target"
    ];
    after = [
      "postgresql.service"
      "network-online.target"
    ];
  };

  # Ensure oauth2-proxy waits for buildbot-master to be ready
  systemd.services.oauth2-proxy = {
    wants = [ "buildbot-master.service" ];
    after = [ "buildbot-master.service" ];
  };

  # Fix DNS resolution timing issue on boot and ensure nginx is ready
  systemd.services."cloudflared-tunnel-9c376bb1-4ca6-49d7-8c36-93908b752ae8" = {
    after = [
      "oauth2-proxy.service"
      "nginx.service"
      "buildbot-master.service"
      "network-online.target"
      "nss-lookup.target"
    ];
    wants = [
      "oauth2-proxy.service"
      "nginx.service"
      "buildbot-master.service"
      "network-online.target"
    ];
    serviceConfig = {
      # Add retry with exponential backoff
      Restart = "on-failure";
      RestartSec = "10s";
      # Give it more time to start
      TimeoutStartSec = "90s";
      # Add a pre-start delay to ensure DNS is ready
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
    };
  };

  services.harmonia.enable = true;
  services.harmonia.signKeyPaths = [ config.age.secrets.x-harmonia-secret.path ];

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    virtualHosts."harmonia.genki.is" = {
      enableACME = true;
      forceSSL = true;
      acmeRoot = null; # Force DNS challenge (HTTP challenge won't work for Tailscale IPs)
      locations."/".extraConfig = ''
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_redirect http:// https://;
        proxy_http_version 1.1;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
      '';
    };
  };

  # Configure nginx virtual hosts (buildbot-nix handles the main config)
  services.nginx.virtualHosts."attic.genki.is" = {
    enableACME = true;
    forceSSL = true;
    acmeRoot = null; # Force DNS challenge instead of webroot
    locations."/" = {
      proxyPass = "http://localhost:8080";
    };
  };

  # Configure ACME to use Cloudflare DNS challenge by default
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "olafur@genkiinstruments.com";
      dnsProvider = "cloudflare";
      environmentFile = "/etc/cloudflared/test";
      webroot = null; # Disable HTTP challenge
    };
  };

  facter.reportPath = ./facter.json;

  users.groups.secrets.members = [
    "oauth2-proxy"
    "buildbot"
  ];
  users.users.root.hashedPassword = "$y$j9T$nDvnJMkeA2vFi99.NQ7oV.$nF/0/2A56QVv8OEJVWf6t/fVk9JL85y220TtS.WHGE/";

  age.secrets =
    let
      mkBuildbotSecret = file: {
        inherit file;
        owner = config.services.buildbot-master.user;
      };
      mkOauth2ProxySecret = file: {
        inherit file;
        owner = "oauth2-proxy";
      };
    in
    {
      buildbot-github-app-secret-key = mkBuildbotSecret "${inputs.secrets}/buildbot-github-app-secret-key.age";
      buildbot-github-oauth-secret = mkBuildbotSecret "${inputs.secrets}/buildbot-github-oauth-secret.age";
      buildbot-github-webhook-secret = mkBuildbotSecret "${inputs.secrets}/buildbot-github-webhook-secret.age";
      buildbot-nix-worker-password = mkBuildbotSecret "${inputs.secrets}/buildbot-nix-worker-password.age";
      buildbot-nix-workers-json = mkBuildbotSecret "${inputs.secrets}/buildbot-nix-workers-json.age";

      buildbot-client-secret = mkOauth2ProxySecret "${inputs.secrets}/buildbot-client-secret.age";
      buildbot-github-cookie-secret = mkOauth2ProxySecret "${inputs.secrets}/buildbot-github-cookie-secret.age";

      buildbot-http-basic-auth-password.file = "${inputs.secrets}/buildbot-http-basic-auth-password.age";
      buildbot-http-basic-auth-password.owner = config.services.buildbot-master.user;
      buildbot-http-basic-auth-password.group = "secrets";
      buildbot-http-basic-auth-password.mode = "0440";

      buildbot-gh-token-for-private-repos.file = "${inputs.secrets}/buildbot-gh-token-for-private-repos.age";
      buildbot-gh-token-for-private-repos.mode = "0440";
      buildbot-gh-token-for-private-repos.owner = "buildbot-worker";

      attic-genki-auth-token.file = "${inputs.secrets}/attic-genki-auth-token.age";
      attic-environment-file.file = "${inputs.secrets}/attic-environment-file.age";

      x-github-runner-key.file = "${inputs.secrets}/x-github-runner-key.age";

      x-cloudflare-tunnel-secret.file = "${inputs.secrets}/x-cloudflare-tunnel-secret.age";

      x-harmonia-secret.file = "${inputs.secrets}/x-harmonia-secret.age";
    };

  # Allows buildbot-worker to pull from private github repositories
  nix.extraOptions = "!include ${config.age.secrets.buildbot-gh-token-for-private-repos.path}";

  services.buildbot-nix.master =
    let
      buildbotAdmins = [
        "multivac61"
        "dingari"
        "MatthewCroughan"
        "saumavel"
        "kalkyl"
      ];
    in
    {
      enable = true;
      useHTTPS = true;
      domain = "buildbot.genki.is";
      outputsPath = "/var/www/buildbot/nix-outputs/";
      workersFile = config.age.secrets.buildbot-nix-workers-json.path;
      buildSystems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      admins = buildbotAdmins;
      # this is a randomly generated secret, which is only used to authenticate requests from the oauth2 proxy to buildbot
      httpBasicAuthPasswordFile = config.age.secrets.buildbot-http-basic-auth-password.path;
      github = {
        enable = true;
        webhookSecretFile = config.age.secrets.buildbot-github-webhook-secret.path;
        oauthId = "Ov23liztqfvRnVaEz57V";
        oauthSecretFile = config.age.secrets.buildbot-github-oauth-secret.path;
        topic = "build-with-buildbot";
        appSecretKeyFile = config.age.secrets.buildbot-github-app-secret-key.path;
        appId = 1163488;
      };
      accessMode.fullyPrivate = {
        backend = "github";
        teams = [ "genkiinstruments" ];
        users = buildbotAdmins;
        # this is a randomly generated alphanumeric secret, which is used to encrypt the cookies set by oauth2-proxy, it must be 8, 16, or 32 characters long
        cookieSecretFile = config.age.secrets.buildbot-github-cookie-secret.path;
        clientSecretFile = config.age.secrets.buildbot-client-secret.path;
        clientId = "Iv23lioyXvbIN5gVi6KN";
      };
    };

  systemd.services.attic-watch-store = {
    description = "Upload all store paths to attic";
    wantedBy = [ "multi-user.target" ];
    environment.HOME = "/var/lib/attic-watch-store";
    after = [
      "network-online.target"
      "atticd.service"
    ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "5s";
      MemoryHigh = "5%";
      MemoryMax = "10%";
      DynamicUser = true;
      StateDirectory = "attic-watch-store";
      LoadCredential = [ "attic-token:${config.age.secrets.attic-genki-auth-token.path}" ];
    };

    path = [ pkgs.attic-client ];
    script = ''
      set -euo pipefail

      # Read token from credentials
      ATTIC_TOKEN=$(< "$CREDENTIALS_DIRECTORY/attic-token")
      export ATTIC_TOKEN

      attic login genki http://${config.services.atticd.settings.listen} "$ATTIC_TOKEN"
      exec attic watch-store genki:genki
    '';
  };

  services.buildbot-nix.worker = {
    enable = true;
    workerPasswordFile = config.age.secrets.buildbot-nix-worker-password.path;
  };

  services.atticd = {
    enable = true;
    environmentFile = config.age.secrets.attic-environment-file.path;

    settings = {
      listen = "[::]:8080";

      # Disable authentication completely
      require-proof-of-possession = false;

      chunking = {
        # The minimum NAR size to trigger chunking
        #
        # If 0, chunking is disabled entirely for newly-uploaded NARs.
        # If 1, all NARs are chunked.
        nar-size-threshold = 64 * 1024; # 64 KiB

        # The preferred minimum size of a chunk, in bytes
        min-size = 16 * 1024; # 16 KiB

        # The preferred average size of a chunk, in bytes
        avg-size = 64 * 1024; # 64 KiB

        # The preferred maximum size of a chunk, in bytes
        max-size = 256 * 1024; # 256 KiB
      };
    };
  };

  # Increase system limits for atticd
  systemd.services.atticd = {
    serviceConfig = {
      # Increase file descriptor limits
      LimitNOFILE = 65536;

      # Override the default RestartSec with mkForce
      RestartSec = pkgs.lib.mkForce 5;

      # Kill only the main process, not children
      KillMode = "mixed";

      # Give more time for graceful shutdown
      TimeoutStopSec = "30s";
    };
    wantedBy = [ "multi-user.target" ];
    before = [ "nginx.service" ];
  };

  # Ensure nginx waits for all backend services
  systemd.services.nginx = {
    after = [
      "atticd.service"
      "harmonia.service"
      "buildbot-master.service"
      "oauth2-proxy.service"
    ];
    wants = [
      "atticd.service"
      "harmonia.service"
      "buildbot-master.service"
      "oauth2-proxy.service"
    ];
  };

  roles.github-actions-runner = {
    url = "https://github.com/genkiinstruments";
    name = "x";
    extraLabels = [ "x-github-runner" ];
    githubApp = {
      id = "1369238";
      login = "genkiinstruments";
      privateKeyFile = config.age.secrets.x-github-runner-key.path;
    };
  };

  # Network tuning for better connection stability
  boot.kernel.sysctl = {
    # Increase TCP buffer sizes for better throughput
    "net.core.rmem_max" = 134217728; # 128MB
    "net.core.wmem_max" = 134217728; # 128MB
    "net.ipv4.tcp_rmem" = "4096 87380 134217728";
    "net.ipv4.tcp_wmem" = "4096 65536 134217728";

    # Increase connection backlog
    "net.core.somaxconn" = 4096;
    "net.ipv4.tcp_max_syn_backlog" = 4096;

    # Better connection handling
    "net.ipv4.tcp_fin_timeout" = 15;
    "net.ipv4.tcp_keepalive_time" = 300;
    "net.ipv4.tcp_keepalive_probes" = 5;
    "net.ipv4.tcp_keepalive_intvl" = 15;

    # Enable TCP Fast Open
    "net.ipv4.tcp_fastopen" = 3;

    # Increase local port range
    "net.ipv4.ip_local_port_range" = "1024 65535";
  };

  system.stateVersion = "24.11";
}
