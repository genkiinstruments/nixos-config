{
  flake,
  pkgs,
  ...
}:
{
  imports = [
    flake.modules.darwin.default
    flake.modules.shared.default
    flake.modules.shared.home-manager
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  networking.hostName = "d";

  users.users.genki = {
    isHidden = false;
    home = "/Users/genki";
    name = "genki";
    shell = pkgs.fish;
  };
  system.primaryUser = "genki";

  # Keyboard remapping configuration
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };

  # Additional keyboard settings via system defaults
  system.defaults = {
    NSGlobalDomain = {
      # Swap Option and Command keys for USB keyboards
      "com.apple.keyboard.fnState" = false;
    };
    
    # Keyboard modifier key mappings
    ".GlobalPreferences" = {
      "com.apple.keyboard.modifiermapping.1452-544-0" = [
        {
          HIDKeyboardModifierMappingSrc = 30064771296;  # Left Option
          HIDKeyboardModifierMappingDst = 30064771299;  # Left Command
        }
        {
          HIDKeyboardModifierMappingSrc = 30064771299;  # Left Command  
          HIDKeyboardModifierMappingDst = 30064771296;  # Left Option
        }
        {
          HIDKeyboardModifierMappingSrc = 30064771300;  # Right Option
          HIDKeyboardModifierMappingDst = 30064771303;  # Right Command
        }
        {
          HIDKeyboardModifierMappingSrc = 30064771303;  # Right Command
          HIDKeyboardModifierMappingDst = 30064771300;  # Right Option
        }
      ];
      
      # Apple keyboard mappings (swap Control and Globe/Fn)
      "com.apple.keyboard.modifiermapping.1452-0-0" = [
        {
          HIDKeyboardModifierMappingSrc = 30064771297;  # Left Control
          HIDKeyboardModifierMappingDst = 1095216660483; # Globe/Fn key
        }
        {
          HIDKeyboardModifierMappingSrc = 1095216660483; # Globe/Fn key
          HIDKeyboardModifierMappingDst = 30064771297;  # Left Control
        }
      ];
    };
  };

  # NOTE: Here you can install packages from brew
  homebrew = {
    enable = true;
    taps = [
      # for things not in the hombrew repo, e.g.,
    ];
    casks = [
      # guis
      "raycast"
      "arc"
    ];
    brews = [
      # clis and libraries
    ];
    masApps = {
      # `nix run nixpkgs#mas -- search <app name>`
      "Keynote" = 409183694;
    };
  };
}
