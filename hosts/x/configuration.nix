{
  inputs,
  flake,
  config,
  pkgs,
  perSystem,
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
    inputs.disko.nixosModules.disko
    inputs.agenix.nixosModules.default
    inputs.nixos-facter-modules.nixosModules.facter
    inputs.buildbot-nix.nixosModules.buildbot-master
    inputs.buildbot-nix.nixosModules.buildbot-worker
    flake.modules.shared.default
    flake.modules.shared.builders
    flake.nixosModules.common
    flake.nixosModules.ssh-serve
    ./disko.nix
  ];

  networking.hostName = "x";

  facter.reportPath = ./facter.json;

  users.groups.secrets.members = [
    "oauth2-proxy"
    "buildbot"
  ];

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

      attic-genki-auth-token.file = "${inputs.secrets}/attic-genki-auth-token.age";
      attic-environment-file.file = "${inputs.secrets}/attic-environment-file.age";
      superbooth-slack-token = {
        file = "${inputs.secrets}/superbooth-slack-token.age";
        owner = "root";
        mode = "0400";
      };
    };

  # Create a systemd service for the Superbooth reminder script
  systemd.services.superbooth-reminder = {
    description = "Superbooth Countdown Reminder";
    script = ''
      export SLACK_TOKEN=$(cat ${config.age.secrets.superbooth-slack-token.path})
      ${perSystem.self.superbooth-reminder}/bin/superbooth-reminder
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    # Will run daily at 9:00AM
    startAt = "09:00:00";
  };

  # Add a systemd timer to stop the service after May 8th, 2025
  systemd.timers.superbooth-reminder-cleanup = {
    description = "Disable Superbooth reminder after May 8th, 2025";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "2025-05-09 00:00:00";
      Unit = "superbooth-reminder-cleanup.service";
    };
  };

  systemd.services.superbooth-reminder-cleanup = {
    description = "Disable Superbooth reminder after May 8th, 2025";
    script = ''
      systemctl disable --now superbooth-reminder.service
      systemctl disable --now superbooth-reminder-cleanup.timer
      echo "Superbooth reminder has been disabled as scheduled."
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

  services.buildbot-nix.master = {
    enable = true;
    useHTTPS = true;
    domain = "${config.networking.hostName}.${tailnet}";
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
              runtimeInputs = [ pkgs.attic-client ];
              text = ''
                # shellcheck disable=SC2101
                attic login genki http://${config.services.atticd.settings.listen} "$ATTIC_TOKEN"

                # shellcheck disable=SC2154
                attic push genki "$path_to_push"
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

  environment.systemPackages = with pkgs; [
    attic-client # the coordinator sends the postBuildStep script over to workers, which doesn’t ensure that the paths are present)
  ];

  services.atticd = {
    enable = true;
    environmentFile = config.age.secrets.attic-environment-file.path;

    settings = {
      listen = "[::]:8080";

      jwt = { };

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

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 90;
  };

  system.stateVersion = "24.11";
}
