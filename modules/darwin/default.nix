{ pkgs, ... }:
{
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
      defaults write -g InitialKeyRepeat -int 8
      defaults write -g KeyRepeat -int 1
      sudo chsh -s ${pkgs.fish}/bin/fish $USER
    '';
  };

  # Automatic garbage collection and nix store optimization
  nix.gc = {
    automatic = true;
    interval = {
      Weekday = 1; # Monday
      Hour = 3; # 3 AM
      Minute = 0;
    };
    options = "--delete-older-than 30d";
  };
  nix.optimise = {
    automatic = true;
    interval = {
      Weekday = 1; # Monday
      Hour = 4; # 4 AM
      Minute = 0;
    };
  };
}
