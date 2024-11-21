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
    inputs.home-manager.darwinModules.home-manager
    inputs.nix-homebrew.darwinModules.nix-homebrew
    inputs.agenix.darwinModules.default
    inputs.self.modules.shared.default
    inputs.self.darwinModules.common
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  age = {
    # Generate manually via `sudo ssh-keygen -A /etc/ssh/` on macOS, using the host key for decryption
    identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets = {
      my-secret = {
        path = "/Users/olafur/Desktop/my-secret";
        file = "${inputs.secrets}/my-secret.age";
        mode = "644";
        owner = "olafur";
        group = "staff";
      };
      atuin-key = {
        path = "/Users/olafur/.local/share/atuin/key";
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
      ssh-serve-m3-gdrn = {
        file = "${inputs.secrets}/ssh-serve-m3-gdrn.age";
        mode = "600";
        owner = "olafur";
        group = "staff";
      };
    };
  };

  home-manager.users.olafur.imports = [ inputs.self.homeModules.default ];
  home-manager.users.olafur.programs.ssh = {
    matchBlocks = {
      "github.com" = {
        user = "git";
        identityFile = "~/.ssh/id_ed25519_sk";
        identitiesOnly = true;
      };
    };
    controlMaster = "auto";
    controlPath = "/tmp/ssh-%u-%r@%h:%p";
    controlPersist = "1800";
    forwardAgent = true;
    addKeysToAgent = "yes";
    serverAliveInterval = 900;
    extraConfig = "SetEnv TERM=xterm-256color";
  };

  users.users.olafur = {
    isHidden = false;
    home = "/Users/olafur";
    shell = pkgs.fish;
  };

  programs.ssh.knownHosts."gdrn".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEkxYcp4RFr6rNaxEZllpW3xVz/lFp/XB3YpgcTazOar";

  environment.systemPackages = with pkgs; [ openssh ]; # needed for fido2 support
  environment.variables.SSH_ASKPASS = "/Applications/ssh-askpass.app/Contents/MacOS/ssh-askpass"; # TODO: nixpkgs
  environment.variables.DISPLAY = ":0";

  environment.interactiveShellInit = ''
    export CACHIX_AUTH_TOKEN="$(cat ${config.age.secrets.cachix_auth_token.path})"
  '';

  nix = {
    settings.trusted-users = [
      "root"
      "@wheel"
      "olafur"
    ];

    linux-builder.enable = true; # Run the aarch64-linux linux-builder as a background service
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "gdrn";
        sshUser = "nix-ssh";
        protocol = "ssh-ng";
        sshKey = config.age.secrets.ssh-serve-m3-gdrn.path;
        system = "x86_64-linux";
        maxJobs = 128;
        # supportedFeatures = [
        #   "big-parallel"
        #   "kvm"
        #   "nixos-test"
        # ];
      }
    ];
  };

  nix-homebrew = {
    user = "olafur";
    enable = true;
    mutableTaps = false;
    taps = with inputs; {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
      "homebrew/homebrew-bundle" = homebrew-bundle;
      "nikitabobko/homebrew-tap" = homebrew-aerospace;
      "zkondor/homebrew-dist" = homebrew-zkondor;
      "theseal/homebrew-ssh-askpass" = homebrew-ssh-askpass;
    };
  };
  homebrew = {
    enable = true;
    casks = [
      "shortcat"
      "raycast"
      "arc"
      "karabiner-elements"
      "nikitabobko/tap/aerospace"
      "zkondor/dist/znotch"
    ];
    brews = [
      "theseal/ssh-askpass/ssh-askpass"
      "bitwarden-cli"
    ];
    caskArgs.no_quarantine = true;
    taps = builtins.attrNames config.nix-homebrew.taps;
    masApps = {
      # `nix run nixpkgs#mas -- search <app name>`
      "Keynote" = 409183694;
      "ColorSlurp" = 1287239339;
      "Numbers" = 409203825;
    };
  };
}
