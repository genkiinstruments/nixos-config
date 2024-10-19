{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    inputs.agenix.darwinModules.default
    inputs.nix-homebrew.darwinModules.nix-homebrew
    inputs.self.modules.shared.default
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  # Generate manually via `sudo ssh-keygen -A /etc/ssh/` on macOS, using the host key for decryption
  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  home-manager.users.genki.imports = [ inputs.self.homeModules.default ];

  users.users.genki = {
    shell = "/run/current-system/sw/bin/fish";
    isHidden = false;
    home = "/Users/genki";
  };
  environment.systemPackages = with pkgs; [ openssh ]; # needed for fido2 support

  programs.fish.enable = true; # Otherwise our shell won't be installed correctly

  nix.settings.trusted-users = [
    "root"
    "@wheel"
    "genki"
  ];

  # TODO: This really is a hack to run actions-runner that was
  # manually installed using: https://github.com/organizations/genkiinstruments/settings/actions/runners/new?arch=arm64&os=osx
  # under folder /Users/genki/actions-runner. The reason we do this is because the github-actions runner
  # in nix-darwin - https://daiderd.com/nix-darwin/manual/index.html#opt-services.github-runners - runs inside a nix container
  # and as such has no acccess to Apple clang and other dependencies needed. 
  # Don't run automatic gc as it may break the actions-runner code.
  launchd.daemons.github-runner = {
    serviceConfig = {
      ProgramArguments = [
        "/bin/sh"
        "-c"
        # follow exact steps of github guide to get this available
        # so more automatic nix version would use pkgs.github-runner (and token sshed as file)
        "/Users/genki/actions-runner/run.sh"
      ];
      Label = "github-runner";
      KeepAlive = true;
      RunAtLoad = true;

      StandardErrorPath = "/Users/genki/actions-runner/err.log";
      StandardOutPath = "/Users/genki/actions-runner/ok.log";
      WorkingDirectory = "/Users/genki/actions-runner/";
      SessionCreate = true;
      UserName = "genki";
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
      # normal minimum is 15 (225 ms)\ defaults write -g KeyRepeat -int 1 # normal minimum is 2 (30 ms)
      defaults write -g InitialKeyRepeat -int 10
      defaults write -g KeyRepeat -int 1
    '';
  };
}
