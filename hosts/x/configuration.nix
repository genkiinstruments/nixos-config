{
  inputs,
  flake,
  config,
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
    flake.modules.nixos.comin
    flake.modules.nixos.zram-swap
    flake.modules.nixos.olafur
    flake.modules.nixos.ssh-serve
    flake.modules.nixos.cloudflared
    ./disko.nix
  ];

  system.stateVersion = "24.11";
  facter.reportPath = ./facter.json;

  genki.builders = [
    {
      hostName = "m2";
      system = "aarch64-linux";
      maxJobs = 15;
    }
    {
      hostName = "gkr";
      system = "aarch64-darwin";
      maxJobs = 3;
    }
  ];

  networking.useDHCP = false;
  networking.interfaces.enp5s0.useDHCP = true;
  networking.interfaces.eno1.useDHCP = true;
  networking.firewall.trustedInterfaces = [
    "enp5s0"
    "eno1"
  ];

  services.cloudflared = {
    enable = true;
    tunnels = {
      "9c376bb1-4ca6-49d7-8c36-93908b752ae8" = {
        credentialsFile = config.age.secrets.x-cloudflare-tunnel-secret.path;
        ingress."buildbot.genki.is" = "http://localhost:80";
        default = "http_status:404";
      };
    };
  };

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

  systemd.services.oauth2-proxy = {
    wants = [ "buildbot-master.service" ];
    after = [ "buildbot-master.service" ];
  };

  # Wait for backend services before starting tunnel
  systemd.services."cloudflared-tunnel-9c376bb1-4ca6-49d7-8c36-93908b752ae8" = {
    after = [
      "oauth2-proxy.service"
      "nginx.service"
      "buildbot-master.service"
    ];
    wants = [
      "oauth2-proxy.service"
      "nginx.service"
      "buildbot-master.service"
    ];
  };

  services.harmonia.enable = true;
  services.harmonia.signKeyPaths = [ config.age.secrets.x-harmonia-secret.path ];

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    appendConfig = "worker_processes auto;"; # use more cores for compression
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

  # Configure ACME to use Cloudflare DNS challenge by default
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "olafur@genkiinstruments.com";
      dnsProvider = "cloudflare";
      environmentFile = "/etc/cloudflared/test";
      webroot = null;
    };
  };

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

      x-github-runner-key.file = "${inputs.secrets}/x-github-runner-key.age";
      x-cloudflare-tunnel-secret.file = "${inputs.secrets}/x-cloudflare-tunnel-secret.age";
      x-harmonia-secret.file = "${inputs.secrets}/x-harmonia-secret.age";
    };

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
        cookieSecretFile = config.age.secrets.buildbot-github-cookie-secret.path;
        clientSecretFile = config.age.secrets.buildbot-client-secret.path;
        clientId = "Iv23lioyXvbIN5gVi6KN";
      };
    };

  services.buildbot-nix.worker = {
    enable = true;
    workerPasswordFile = config.age.secrets.buildbot-nix-worker-password.path;
  };

  systemd.services.nginx = {
    after = [
      "harmonia.service"
      "buildbot-master.service"
      "oauth2-proxy.service"
    ];
    wants = [
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

}
