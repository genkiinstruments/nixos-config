{ lib, pkgs, user, host, ... }:

{
  imports = [
    ../../modules/darwin/home-manager.nix
    ../../modules/shared
    ../../modules/shared/cachix
  ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Setup user, packages, programs
  nix = {
    settings.trusted-users = [ "@admin" "${user}" ];

    gc = {
      user = "root";
      automatic = true;
      interval = { Weekday = 0; Hour = 2; Minute = 0; };
      options = "--delete-older-than 30d";
    };
  };

  services.github-runners.${host} = {
    enable = true;
    # ephemeral = true;
    replace = true;
    tokenFile = "/Users/genki/github-access-token";
    url = "https://github.com/genkiinstruments/software";
    extraLabels = [ "mac-self-hosted" ];
    extraPackages = with pkgs; [
      cachix
      nix # Need to use nix inside our actions
      # Stuff present in github action runners
      coreutils
      which
      jq
      # https://github.com/actions/upload-pages-artifact/blob/56afc609e74202658d3ffba0e8f6dda462b719fa/action.yml#L40
      (runCommandNoCC "gtar" { } ''
        mkdir -p $out/bin
        ln -s ${lib.getExe gnutar} $out/bin/gtar
      '')
    ];
  };

  # Turn off NIX_PATH warnings now that we're using flakes
  system.checks.verifyNixPath = false;

  # Enable fonts dir
  fonts.fontDir.enable = true;

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
  };
}
