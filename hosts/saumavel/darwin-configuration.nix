{
  flake,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.srvos.darwinModules.common
    inputs.srvos.darwinModules.mixins-terminfo
    flake.modules.darwin.default
    flake.modules.darwin.secretive
    flake.modules.shared.default
    flake.modules.shared.home-manager
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  system.primaryUser = "saumavel";

  users.users.saumavel = {
    isHidden = false;
    home = "/Users/saumavel";
    shell = pkgs.fish;
  };

  # Fix nixbld group ID issue
  ids.gids.nixbld = 350;

  system = {
    defaults = {
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        KeyRepeat = 2; # 120, 90, 60, 30, 12, 6, 2
        InitialKeyRepeat = 15; # 120, 94, 68, 35, 25, 15
        "com.apple.keyboard.fnState" = true; # Make F1, F2, etc. keys behave as standard function keys
        NSAutomaticCapitalizationEnabled = false;

        ApplePressAndHoldEnabled = false;
        "com.apple.trackpad.forceClick" = false; # Disables Force Click
        "com.apple.trackpad.scaling" = 1.0; # Configures the trackpad tracking speed (0 to 3). The default is “1”.AppleShowAllFiles = true;
      };

      ".GlobalPreferences" = {
        "com.apple.mouse.scaling" = 2.0; # Configures the mouse tracking speed (0 to 3). The default is “1.5”.
      };

      finder = {
        AppleShowAllFiles = true;
        FXPreferredViewStyle = "clmv";
        FXDefaultSearchScope = "SCcf";
        FXRemoveOldTrashItems = true;
        ShowPathbar = true;
      };

      screencapture = {
        location = "~/Downloads/";
        type = "png";
      };

      trackpad = {
        TrackpadThreeFingerTapGesture = 0; # Disables the three-finger tap for dictionary lookup
      };

      magicmouse = {
        MouseButtonMode = "TwoButton";
      };
    };

    keyboard = {
      enableKeyMapping = true;
    };

    activationScripts.postActivation.text = ''
      # normal minimum is 15 (225 ms)\ defaults write -g KeyRepeat -int 1 # normal minimum is 2 (30 ms)
      defaults write -g InitialKeyRepeat -int 10 
      defaults write -g KeyRepeat -int 1
    '';
  };

  # Modified homebrew configuration to update but not remove packages
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true; # Update Homebrew and formulae
      upgrade = true; # Upgrade outdated packages
      cleanup = "none"; # Don't remove any packages not in the list
    };
    brews = [
      "nvm"
      "node"
      "clang-format"
      "luarocks"
      # "biber"
      # "texlive"
      # "xdotool"
    ];
    casks = [
      # MEGA UTILITIES
      "raycast"
      "alt-tab"
      "karabiner-elements"
      "screen-studio"

      # UTILITIES
      "keyboardcleantool"
      "logi-options+"
      "the-unarchiver"
      "postman"

      # WORK
      "obsidian"
      "slack"
      "linear-linear"

      # BROWSERS
      "arc"

      # CHAT
      "messenger"

      # FUN
      "bitwig-studio"
      "plex"

      # IDE´s
      "zed"
      "visual-studio-code"
    ];
    masApps = {
      # `nix run nixpkgs #mas -- search <app name>`
      "Keynote" = 409183694;
      "Pages" = 409201541;
    };
  };
}
