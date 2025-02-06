{
  config,
  inputs,
  pkgs,
  perSystem,
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
      ssh-serve-m3-gdrn = {
        file = "${inputs.secrets}/ssh-serve-m3-gdrn.age";
        mode = "600";
        owner = "olafur";
        group = "staff";
      };
    };
  };

  home-manager.users.olafur.imports = [ inputs.self.homeModules.default ];
  home-manager.users.olafur.programs.atuin.settings.key_path = config.age.secrets.atuin-key.path;
  home-manager.users.olafur.home.activation.setup-mvim =
    ''${perSystem.self.setup-mvim}/bin/setup-mvim'';
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
  home-manager.users.olafur.programs.fish.interactiveShellInit = ''
    #-------------------------------------------------------------------------------
    # SSH Agent
    #-------------------------------------------------------------------------------
    function __ssh_agent_is_started -d "check if ssh agent is already started"
        if begin
                test -f $SSH_ENV; and test -z "$SSH_AGENT_PID"
            end
            source $SSH_ENV >/dev/null
        end

        if test -z "$SSH_AGENT_PID"
            return 1
        end

        ${pkgs.openssh}/bin/ssh-add -l >/dev/null 2>&1
        if test $status -eq 2
            return 1
        end
    end

    function __ssh_agent_start -d "start a new ssh agent"
        ${pkgs.openssh}/bin/ssh-agent -c | sed 's/^echo/#echo/' >$SSH_ENV
        chmod 600 $SSH_ENV
        source $SSH_ENV >/dev/null
        ${pkgs.openssh}/bin/ssh-add
    end

    if not test -d $HOME/.ssh
        mkdir -p $HOME/.ssh
        chmod 0700 $HOME/.ssh
    end

    if test -z "$SSH_ENV"
        set -xg SSH_ENV $HOME/.ssh/environment
    end

    if not __ssh_agent_is_started
        __ssh_agent_start
    end
  '';

  users.users.olafur = {
    isHidden = false;
    home = "/Users/olafur";
    shell = pkgs.fish;
  };

  programs.ssh.knownHosts."gdrn".publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEkxYcp4RFr6rNaxEZllpW3xVz/lFp/XB3YpgcTazOar";

  environment.systemPackages = with pkgs; [
    openssh # needed for fido2 support
    aerospace
  ];
  environment.variables.SSH_ASKPASS = "/Applications/ssh-askpass.app/Contents/MacOS/ssh-askpass"; # TODO: nixpkgs
  environment.variables.DISPLAY = ":0";

  system.activationScripts.setup-mvim = {
    text = ''
      ${perSystem.self.setup-mvim}/bin/setup-mvim
    '';
  };

  environment.interactiveShellInit = ''
    export CACHIX_AUTH_TOKEN="$(cat ${config.age.secrets.cachix_auth_token.path})"
  '';

  nix = {
    settings.trusted-users = [
      "root"
      "@wheel"
      "olafur"
    ];

    linux-builder.enable = true;
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
