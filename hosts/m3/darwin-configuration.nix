{
  config,
  inputs,
  pkgs,
  ...
}:
let
  user = "olafur";
  userName = "Ólafur Bjarki Bogason";
  userEmail = "olafur@genkiinstruments.com";
in
{
  imports = [
    inputs.srvos.darwinModules.common
    inputs.home-manager.darwinModules.home-manager
    inputs.nix-homebrew.darwinModules.nix-homebrew
    inputs.agenix.darwinModules.default
    ../../modules/shared
  ];
  nixpkgs.hostPlatform = "aarch64-darwin";
  nix-homebrew = {
    inherit user;
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
  age = {
    identityPaths = [
      # Generate manually via `sudo ssh-keygen -A /etc/ssh/` on macOS, using the host key for decryption
      "/etc/ssh/ssh_host_ed25519_key"
    ];
    secrets = {
      my-secret = {
        symlink = true;
        path = "/Users/${user}/Desktop/my-secret";
        file = "${inputs.secrets}/my-secret.age";
        mode = "644";
        owner = "${user}";
        group = "staff";
      };
      atuin-key = {
        symlink = true;
        path = "/Users/${user}/.local/share/atuin/key";
        file = "${inputs.secrets}/atuin-key.age";
        mode = "644";
        owner = "${user}";
        group = "staff";
      };
    };
  };
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "backup";
  home-manager.users.${user} =
    { config, ... }:
    {
      imports = [
        inputs.nix-index-database.hmModules.nix-index
        inputs.catppuccin.homeManagerModules.catppuccin
        ../../modules/shared/home.nix
      ];
      catppuccin = {
        enable = true;
        flavor = "mocha";
      };
      programs.git = {
        inherit userEmail userName;
      };
      programs.ssh = {
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
      home.file.".config/karabiner/karabiner.json".source = ../../modules/darwin/config/karabiner/karabiner.json; # Hyper-key config
    };
  users.users.${user} =
    { pkgs, ... }:
    {
      isHidden = false;
      home = "/Users/${user}";
      shell = pkgs.fish;
    };
  environment.systemPackages = with pkgs; [ openssh ]; # needed for fido2 support
  environment.variables.SSH_ASKPASS = "/opt/homebrew/bin/ssh-askpass";
  environment.variables.DISPLAY = ":0";
  environment.loginShell = "fish";
  programs.fish.enable = true;
  nix.settings.trusted-users = [
    "root"
    "@wheel"
    "${user}"
  ]; # Otherwise we get complaints
  # Enable tailscale. We manually authenticate when we want with `tailscale up`
  services.tailscale.enable = true;

  # Auto upgrade nix package and the daemon service (multi-user install, aborting activation
  services.nix-daemon.enable = true;

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
    activationScripts.postUserActivation.text = ''
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';
    # https://github.com/LnL7/nix-darwin/issues/811
    activationScripts.setFishAsShell.text = ''
      dscl . -create /Users/olafur UserShell /run/current-system/sw/bin/fish
    '';

  };
}
