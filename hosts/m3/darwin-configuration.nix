{
  config,
  inputs,
  pkgs,
  flake,
  ...
}:
{
  imports = [
    inputs.srvos.darwinModules.common
    inputs.srvos.darwinModules.mixins-terminfo
    inputs.agenix.darwinModules.default
    flake.modules.shared.default
    flake.modules.shared.builders
    flake.modules.shared.home-manager
    flake.darwinModules.common
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  age = {
    # Generate manually via `sudo ssh-keygen -A /etc/ssh/` on macOS, nixos use builtin /etc/ssh/ssh_host_ed25519_key
    identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets = {
      atuin-key = {
        file = "${inputs.secrets}/atuin-key.age";
        mode = "644";
        owner = "olafur";
        group = "staff";
      };
      cachix_auth_token = {
        file = "${inputs.secrets}/m3-CACHIX_AUTH_TOKEN.age";
        mode = "644";
        owner = "olafur";
        group = "staff";
      };
    };
  };

  nix.settings = {
    substituters = [ "https://genki.cachix.org" ];
    trusted-public-keys = [ "genki.cachix.org-1:5l+wAa4rDwhcd5Wm43eK4N73qJ6GIKmJQ87Nw/bRGfE=" ];
    trusted-users = [ "olafur" ];
  };

  home-manager.users.olafur.programs.atuin.settings.key_path = config.age.secrets.atuin-key.path;

  system.primaryUser = "olafur";
  users.users.olafur = {
    isHidden = false;
    home = "/Users/olafur";
    shell = pkgs.fish;
  };

  environment.interactiveShellInit = ''
    export CACHIX_AUTH_TOKEN="$(cat ${config.age.secrets.cachix_auth_token.path})"
  '';
  # TODO: Failed to update: https://github.com/LnL7/nix-darwin/blob/a6746213b138fe7add88b19bafacd446de574ca7/modules/system/checks.nix#L93
  ids.gids.nixbld = 350;

  environment.etc."ssh/ssh_config.d/secretive.conf".text = ''
    Host *
      IdentityAgent ~/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh
  '';

  homebrew = {
    enable = true;
    casks = [
      # guis
      "shortcat"
      "raycast"
      "arc"
      "firefox"
      "secretive"
      "kicad"
      "tailscale"
    ];
    brews = [
      # clis and libraries
      "age-plugin-se"
    ];
    taps = [
      # for things not in the hombrew repo, e.g.,
    ];
    masApps = {
      # `nix run nixpkgs#mas -- search <app name>`
      Keynote = 409183694;
      ColorSlurp = 1287239339;
      Numbers = 409203825;
      WhatsApp = 310633997;
    };
  };
}
