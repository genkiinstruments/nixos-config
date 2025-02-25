{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.srvos.darwinModules.common
    inputs.srvos.darwinModules.mixins-telegraf
    inputs.srvos.darwinModules.mixins-terminfo
    inputs.srvos.darwinModules.mixins-nix-experimental
    inputs.agenix.darwinModules.default
    inputs.self.modules.shared.default
    inputs.self.modules.shared.home-manager
    inputs.self.darwinModules.common
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
      nix-ssh-m3-v1 = {
        file = "${inputs.secrets}/nix-ssh-m3-v1.age";
        mode = "600";
        owner = "olafur";
        group = "staff";
      };
      nix-ssh-m3-gdrn = {
        file = "${inputs.secrets}/nix-ssh-m3-gdrn.age";
        mode = "600";
        owner = "olafur";
        group = "staff";
      };
    };
  };

  home-manager.users.olafur.programs.atuin.settings.key_path = config.age.secrets.atuin-key.path;

  users.users.olafur = {
    isHidden = false;
    home = "/Users/olafur";
    shell = pkgs.fish;
  };

  environment.systemPackages = with pkgs; [
    openssh # needed for fido2 support
  ];
  environment.variables.SSH_ASKPASS = "/Applications/ssh-askpass.app/Contents/MacOS/ssh-askpass"; # TODO: nixpkgs
  environment.variables.DISPLAY = ":0";

  environment.interactiveShellInit = ''
    export CACHIX_AUTH_TOKEN="$(cat ${config.age.secrets.cachix_auth_token.path})"
  '';
  # TODO: Failed to update: https://github.com/LnL7/nix-darwin/blob/a6746213b138fe7add88b19bafacd446de574ca7/modules/system/checks.nix#L93
  ids.gids.nixbld = 350;

  nix = {
    settings.trusted-users = [
      "root"
      "@wheel"
      "olafur"
    ];
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "gdrn";
        sshUser = "nix-ssh";
        protocol = "ssh-ng";
        systems = [ "aarch64-linux" ];
        maxJobs = 128;
        sshKey = config.age.secrets.nix-ssh-m3-gdrn.path;
        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUl1UHF1RTUwNDVZcUFwZ2swdzBrU0d5ZHBhbDVaTVNmTWlablR6MHVOWDMgcm9vdEBnZHJuCg==";
        supportedFeatures = [
          "nixos-test"
          "benchmark"
          "big-parallel"
          "kvm"
        ];
      }
      {
        hostName = "v1";
        sshUser = "nix-ssh";
        protocol = "ssh-ng";
        systems = [
          "aarch64-linux"
          "x86_64-linux"
        ];
        maxJobs = 128;
        sshKey = config.age.secrets.nix-ssh-m3-v1.path;
        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUd1K2prYmJ2WVVndDN3azFFdEd5VXBHVDZMQ0EzUklBa1M0L0JjVzdEeHUgcm9vdEBtM3ZtCg==";
        supportedFeatures = [
          "nixos-test"
          "benchmark"
          "big-parallel"
          "kvm"
        ];
      }
    ];
  };

  homebrew = {
    enable = true;
    casks = [
      # guis
      "shortcat"
      "raycast"
      "arc"
      "karabiner-elements"
    ];
    brews = [
      # clis and libraries
      "theseal/ssh-askpass/ssh-askpass"
      "bitwarden-cli"
    ];
    taps = [
      {
        name = "theseal/ssh-askpass";
        clone_target = "https://github.com/theseal/ssh-askpass.git";
        force_auto_update = true;
      }
    ];
    masApps = {
      # `nix run nixpkgs#mas -- search <app name>`
      "Keynote" = 409183694;
      "ColorSlurp" = 1287239339;
      "Numbers" = 409203825;
    };
  };
}
