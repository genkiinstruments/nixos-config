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
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  age = {
    # Generate manually via `sudo ssh-keygen -A /etc/ssh/` on macOS, using the host key for decryption
    identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets = {
      my-secret = {
        symlink = true;
        path = "/Users/olafur/Desktop/my-secret";
        file = "${inputs.secrets}/my-secret.age";
        mode = "644";
        owner = "olafur";
        group = "staff";
      };
      atuin-key = {
        symlink = true;
        path = "/Users/olafur/.local/share/atuin/key";
        file = "${inputs.secrets}/atuin-key.age";
        mode = "644";
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

  environment.systemPackages = with pkgs; [ openssh ]; # needed for fido2 support
  environment.variables.SSH_ASKPASS = "/opt/homebrew/bin/ssh-askpass"; # TODO: nixpkgs
  environment.variables.DISPLAY = ":0";

  nix.settings.trusted-users = [
    "root"
    "@wheel"
    "olafur"
  ];

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

  system = {
    stateVersion = 4;

    defaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;

        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.volume" = 0.0;
        "com.apple.sound.beep.feedback" = 0;
      };

      dock = {
        autohide = true;
        show-recents = false;
        tilesize = 72;
        orientation = "left";
      };

      finder = {
        _FXShowPosixPathInTitle = false;
      };

      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };
    };

    activationScripts.postActivation.text = ''
      # normal minimum is 15 (225 ms)\ defaults write -g KeyRepeat -int 1 # normal minimum is 2 (30 ms)
      defaults write -g InitialKeyRepeat -int 10
      defaults write -g KeyRepeat -int 1
    '';

    # reload the settings and apply them without the need to logout/login
    activationScripts.postUserActivation.text = "/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u";
    # https://github.com/LnL7/nix-darwin/issues/811
    activationScripts.setFishAsShell.text = "dscl . -create /Users/olafur UserShell /run/current-system/sw/bin/fish";
  };
}
