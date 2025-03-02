{
  inputs,
  flake,
  ...
}:
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
    flake.nixosModules.common
    ./disko.nix
  ];

  networking.hostName = "x";

  facter.reportPath = ./facter.json;

  users.users.root.openssh.authorizedKeys.keyFiles = [ "${flake}/authorized_keys" ];

  services.buildbot-nix.master = {
    enable = true;

    domain = "buildbot.bygenki.com";
    workersFile = pkgs.writeText "workers.json" "changeMe";
    admins = [
      "multivac61"
      "dingari"
    ];

    authBackend = "httpbasicauth";
    # this is a randomly generated secret, which is only used to authenticate requests from the oauth2 proxy to buildbot
    httpBasicAuthPasswordFile = pkgs.writeText "http-basic-auth-passwd" "changeMe";

    github = {
      enable = true;
      webhookSecretFile = pkgs.writeText "github_webhook_secret" "changeMe";
      topic = "build-with-buildbot";
      authType.app = {
        secretKeyFile = pkgs.writeText "github_app_secret_key" "changeMe";
        id = 1163488;
      };
    };

    accessMode.fullyPrivate = {
      backend = "github";
      # this is a randomly generated alphanumeric secret, which is used to encrypt the cookies set by oauth2-proxy, it must be 8, 16, or 32 characters long
      cookieSecretFile = pkgs.writeText "github_cookie_secret" "changeMe";
      clientSecretFile = pkgs.writeText "github_oauth_secret" "changeMe";
      clientId = "Iv1.XXXXXXXXXXXXXXXX";
    };
  };

  services.buildbot-nix.worker = {
    enable = true;
    workerPasswordFile = "/secret/worker_secret";
  };

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

  system.stateVersion = "24.11";
}
