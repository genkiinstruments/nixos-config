{
  lib,
  pkgs,
  user,
  ...
}:
{
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
  };

  # TODO: This really is a hack to run actions-runner that was
  # manually installed using: https://github.com/organizations/genkiinstruments/settings/actions/runners/new?arch=arm64&os=osx
  # under folder /Users/genki/actions-runner. The reason we do this is because the github-actions runner
  # in nix-darwin - https://daiderd.com/nix-darwin/manual/index.html#opt-services.github-runners - runs inside a nix container
  # and as such has no acccess to Apple clang and other dependencies needed. 
  # NOTE: Don't run automatic gc as it may break the actions-runner code.
  launchd.daemons.github-runner = {
    serviceConfig = {
      ProgramArguments = [
        "/bin/sh"
        "-c"
        # follow exact steps of github guide to get this available
        # so more automatic nix version would use pkgs.github-runner (and token sshed as file)
        "/Users/${user}/actions-runner/run.sh"
      ];
      Label = "github-runner";
      KeepAlive = true;
      RunAtLoad = true;

      StandardErrorPath = "/Users/${user}/actions-runner/err.log";
      StandardOutPath = "/Users/${user}/actions-runner/ok.log";
      WorkingDirectory = "/Users/${user}/actions-runner/";
      SessionCreate = true;
      UserName = "${user}";
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
