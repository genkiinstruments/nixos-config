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
    flake.modules.shared.comin-exporter
    flake.modules.shared.systemd-exporter
    flake.modules.nixos.default
    flake.modules.nixos.ssh-serve
    flake.modules.nixos.comin
    ./disko.nix
  ];

  networking.hostName = "x";

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

  # Fix DNS resolution timing issue on boot
  systemd.services."cloudflared-tunnel-9c376bb1-4ca6-49d7-8c36-93908b752ae8" = {
    after = [
      "network-online.target"
      "nss-lookup.target"
    ];
    wants = [
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
    };

  # Allows buildbot-worker to pull from private github repositories
  nix.extraOptions = "!include ${config.age.secrets.buildbot-gh-token-for-private-repos.path}";

  services.buildbot-nix.master = {
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
    admins = [
      "multivac61"
      "dingari"
      "MatthewCroughan"
    ];
    # this is a randomly generated secret, which is only used to authenticate requests from the oauth2 proxy to buildbot
    httpBasicAuthPasswordFile = config.age.secrets.buildbot-http-basic-auth-password.path;
    github = {
      enable = true;
      webhookSecretFile = config.age.secrets.buildbot-github-webhook-secret.path;
      oauthId = "Ov23liztqfvRnVaEz57V";
      oauthSecretFile = config.age.secrets.buildbot-github-oauth-secret.path;
      topic = "build-with-buildbot";
      authType.app.secretKeyFile = config.age.secrets.buildbot-github-app-secret-key.path;
      authType.app.id = 1163488;
    };
    accessMode.fullyPrivate = {
      backend = "github";
      teams = [ "genkiinstruments" ];
      users = [
        "multivac61"
        "dingari"
        "MatthewCroughan"
      ];
      # this is a randomly generated alphanumeric secret, which is used to encrypt the cookies set by oauth2-proxy, it must be 8, 16, or 32 characters long
      cookieSecretFile = config.age.secrets.buildbot-github-cookie-secret.path;
      clientSecretFile = config.age.secrets.buildbot-client-secret.path;
      clientId = "Iv23lioyXvbIN5gVi6KN";
    };
    postBuildSteps = [
      {
        name = "Push to attic";
        environment.path_to_push = inputs.buildbot-nix.lib.interpolate "%(prop:out_path)s";
        environment.ATTIC_TOKEN = inputs.buildbot-nix.lib.interpolate "%(secret:attic-auth-token)s";
        command = [
          (pkgs.lib.getExe (
            pkgs.writeShellApplication {
              name = "push-to-attic";
              runtimeInputs = [
                pkgs.attic-client
                pkgs.curl
              ];
              text = ''
                # shellcheck disable=SC2101
                attic login genki http://${config.services.atticd.settings.listen} "$ATTIC_TOKEN"

                # shellcheck disable=SC2154
                # path_to_push is provided by buildbot-nix environment
                # More robust retry logic with connection health checks
                MAX_RETRIES=5
                BASE_DELAY=2
                MAX_DELAY=60

                # Test connection first
                echo "Testing connection to attic server..."
                if ! curl -sf -m 5 "http://${config.services.atticd.settings.listen}/api/v1/cache/genki" >/dev/null 2>&1; then
                  echo "Warning: Initial connection test failed, but proceeding..."
                fi

                # Function to calculate delay with jitter
                calculate_delay() {
                  local attempt=$1
                  local base_delay=$((BASE_DELAY * (2 ** (attempt - 1))))
                  local delay=$((base_delay < MAX_DELAY ? base_delay : MAX_DELAY))
                  # Add 10-30% jitter
                  local jitter=$((delay * (10 + RANDOM % 20) / 100))
                  echo $((delay + jitter))
                }

                # Retry push with enhanced error handling
                for attempt in $(seq 1 $MAX_RETRIES); do
                  echo "Attempt $attempt/$MAX_RETRIES to push to attic..."
                  
                  # Set timeout for the push operation
                  export ATTIC_TIMEOUT=300  # 5 minutes
                  
                  # Try push with error capture
                  # shellcheck disable=SC2154
                  if output=$(attic push genki "$path_to_push" 2>&1); then
                    echo "Push succeeded on attempt $attempt"
                    exit 0
                  else
                    exit_code=$?
                    echo "Push failed on attempt $attempt (exit code: $exit_code)"
                    echo "Error output: $output"
                    
                    # Check for specific error patterns
                    if echo "$output" | grep -q "connection closed before message completed"; then
                      echo "Connection was interrupted - this is recoverable"
                    elif echo "$output" | grep -q "error sending request"; then
                      echo "Network error detected - will retry"
                    fi
                    
                    if [ "$attempt" -lt "$MAX_RETRIES" ]; then
                      delay=$(calculate_delay "$attempt")
                      echo "Waiting $delay seconds before retry..."
                      sleep "$delay"
                      
                      # Test connection before next attempt
                      if ! curl -sf -m 5 "http://${config.services.atticd.settings.listen}/api/v1/cache/genki" >/dev/null 2>&1; then
                        echo "Connection test failed, but continuing with retry..."
                      fi
                    fi
                  fi
                done

                echo "All $MAX_RETRIES push attempts failed"
                # Exit with special code to indicate retry exhaustion
                exit 111
              '';
            }
          ))
        ];
      }
    ];
  };
  systemd.services.buildbot-master.serviceConfig.LoadCredential = [
    "attic-auth-token:${config.age.secrets.attic-genki-auth-token.path}"
  ];

  services.buildbot-nix.worker = {
    enable = true;
    workerPasswordFile = config.age.secrets.buildbot-nix-worker-password.path;
  };

  # the coordinator sends the postBuildStep script over to workers, which doesn’t ensure that the paths are present)
  environment.systemPackages = with pkgs; [ attic-client ];

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

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 90;
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
      "dialout"
      "video"
      "inputs"
    ];
    openssh.authorizedKeys.keyFiles = [ "${flake}/authorized_keys" ];
  };
  nix.settings.trusted-users = [ "olafur" ];
}
