{ lib, pkgs, user, host, ... }:

{
  imports = [
    ../../modules/darwin/home-manager.nix
    ../../modules/shared
    ../../modules/shared/cachix
  ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Enable tailscale. We manually authenticate when we want with
  # "sudo tailscale up". If you don't use tailscale, you should comment
  # out or delete all of this.
  services.tailscale.enable = true;

  # Setup user, packages, programs
  nix = {
    settings.trusted-users = [ "@admin" "${user}" "github-runner" ];

    gc = {
      user = "root";
      automatic = true;
      interval = { Weekday = 0; Hour = 2; Minute = 0; };
      options = "--delete-older-than 30d";
    };
  };

  # Github runner CI
  users = {
    knownUsers = [ "github-runner" ];
    forceRecreate = true;
    users.github-runner = {
      uid = 1009;
      description = "GitHub Runner";
      home = "/Users/github-runner";
      createHome = true;
      shell = pkgs.bashInteractive;
      # NOTE: Go to macOS Remote-Login settings and allow all users to ssh.
      openssh.authorizedKeys.keys = [
        # github-runner VM's /etc/ssh/ssh_host_ed25519_key.pub
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGqWL96+z6Wk2IgF6XRyoZAVUXmCmP8I78dUpA4Qy4bh genki@gdrn"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ1uxevLNJOPIPRMh9G9fFSqLtYjK5R7+nRdtsas2KwX olafur@M3.localdomain"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINksz7jbqMHoWlBebyPwMW8uvsgp2fhmRVDwR+Am5LQm genki@gkr"
      ];
    };
  };

  services.github-runners.${host} = {
    enable = true;
    replace = true;

    tokenFile = "/Users/Shared/token";
    url = "https://github.com/genkiinstruments";

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
      rclone
      python3
      pandoc
      gh
      ninja
      cmake
      python312Packages.intelhex
    ];
    extraEnvironment = {
      # NOTE: Make use of Apple clang.. I know this is not the best way to do it, but it works for now....
      PATH = "/run/wrappers/bin /usr/local/bin /System/Cryptexes/App/usr/bin /usr/bin /bin /usr/sbin /sbin /var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin /var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin /var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin";
    };
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
