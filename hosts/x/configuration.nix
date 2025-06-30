{
  inputs,
  flake,
  config,
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
    inputs.nixos-facter-modules.nixosModules.facter
    inputs.buildbot-nix.nixosModules.buildbot-master
    inputs.buildbot-nix.nixosModules.buildbot-worker
    flake.modules.shared.default
    flake.modules.shared.builders
    flake.modules.shared.home-manager
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

      attic-genki-auth-token.file = "${inputs.secrets}/attic-genki-auth-token.age";
      attic-environment-file.file = "${inputs.secrets}/attic-environment-file.age";

      x-github-runner-key.file = "${inputs.secrets}/x-github-runner-key.age";
    };

  # Fix SSL deprecation warnings that break GitHub status reporting
  systemd.services.buildbot-master.environment = {
    PYTHONWARNINGS = "ignore";
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
      "plugdev"
      "dialout"
      "video"
      "inputs"
    ];
    openssh.authorizedKeys.keyFiles = [ "${flake}/authorized_keys" ];
  };
  nix.settings.trusted-users = [ "olafur" ];
}
