{
  config,
  lib,
  pkgs,
  user,
  ...
}:
{
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
