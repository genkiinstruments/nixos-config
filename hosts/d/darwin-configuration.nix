{
  flake,
  inputs,
  ...
}:
{
  imports = [
    inputs.srvos.darwinModules.desktop
    inputs.srvos.darwinModules.mixins-trusted-nix-caches
    flake.modules.darwin.default
    flake.modules.darwin.secretive
    flake.modules.darwin.user
    flake.modules.shared.default
    flake.modules.shared.builders
    flake.modules.shared.home-manager
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  genki.user = "genki";

  genki.builders = [
    {
      hostName = "x";
      system = "x86_64-linux";
      maxJobs = 23;
    }
    {
      hostName = "m2";
      system = "aarch64-linux";
      maxJobs = 15;
    }
  ];

  # Keyboard remapping configuration
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;

    # Custom key mappings for USB and Apple keyboards
    userKeyMapping = [
      # USB keyboards: swap Option and Command
      {
        HIDKeyboardModifierMappingSrc = 30064771298; # Left Option (0x7000000E2)
        HIDKeyboardModifierMappingDst = 30064771299; # Left Command (0x7000000E3)
      }
      {
        HIDKeyboardModifierMappingSrc = 30064771299; # Left Command (0x7000000E3)
        HIDKeyboardModifierMappingDst = 30064771298; # Left Option (0x7000000E2)
      }
      {
        HIDKeyboardModifierMappingSrc = 30064771302; # Right Option (0x7000000E6)
        HIDKeyboardModifierMappingDst = 30064771303; # Right Command (0x7000000E7)
      }
      {
        HIDKeyboardModifierMappingSrc = 30064771303; # Right Command (0x7000000E7)
        HIDKeyboardModifierMappingDst = 30064771302; # Right Option (0x7000000E6)
      }
      # Apple keyboards: swap Control and Globe/Fn
      {
        HIDKeyboardModifierMappingSrc = 30064771296; # Left Control (0x7000000E0)
        HIDKeyboardModifierMappingDst = 1879048195; # Globe/Fn key (0x700000063)
      }
      {
        HIDKeyboardModifierMappingSrc = 1879048195; # Globe/Fn key (0x700000063)
        HIDKeyboardModifierMappingDst = 30064771296; # Left Control (0x7000000E0)
      }
    ];
  };

  # System defaults for keyboard behavior
  system.defaults = {
    NSGlobalDomain = {
      # Function key behavior
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

  # Fix nixbld group ID issue
  ids.gids.nixbld = 350;

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
      "zed"
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
