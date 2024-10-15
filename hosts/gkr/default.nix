{
  lib,
  pkgs,
  user,
  config,
  secrets,
  ...
}:
{
  age.secrets.gkr-github-runner.file = "${secrets}/gkr-github-runner.age";
  age.secrets.gkr-github-runner.owner =
    config.launchd.daemons.github-runner-runner.serviceConfig.UserName;

  services.github-runners.runner = {
    enable = true;
    replace = true;
    name = "gkr-github-runner";
    url = "https://github.com/genkiinstruments";
    tokenFile = config.age.secrets.gkr-github-runner.path;
    extraPackages = with pkgs; [
      bash
      coreutils
      git
      gnutar
      gzip
      cachix
      nix
    ];
  };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Enable tailscale. We manually authenticate when we want with
  # "sudo tailscale up". If you don't use tailscale, you should comment
  # out or delete all of this.
  services.tailscale.enable = true;

  # Setup user, packages, programs
  nix = {
    settings.trusted-users = [
      "@admin"
      "${user}"
      "github-runner"
    ];

    gc = {
      user = "root";
      # automatic = true;
      interval = {
        Weekday = 0;
        Hour = 2;
        Minute = 0;
      };
      options = "--delete-older-than 30d";
    };
  };

  system = {
    stateVersion = 4;

    defaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;

        # 120, 90, 60, 30, 12, 6, 2
        KeyRepeat = 2;

        # 120, 94, 68, 35, 25, 15
        InitialKeyRepeat = 15;

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

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };

    activationScripts.postActivation.text = ''
      # Set the default shell as fish for the user
      sudo chsh -s ${lib.getBin pkgs.fish}/bin/fish "${user}"

      # normal minimum is 15 (225 ms)\ defaults write -g KeyRepeat -int 1 # normal minimum is 2 (30 ms)
      defaults write -g InitialKeyRepeat -int 10 
      defaults write -g KeyRepeat -int 1
    '';

    # https://github.com/LnL7/nix-darwin/issues/811
    activationScripts.setFishAsShell.text = ''
      dscl . -create /Users/olafur UserShell /run/current-system/sw/bin/fish
    '';
  };
}
