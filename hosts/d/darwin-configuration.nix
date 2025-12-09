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

    # Only apply Option/Command swap for USB keyboards
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
    ];
  };

  # System defaults for keyboard behavior
  system.defaults.NSGlobalDomain."com.apple.keyboard.fnState" = false;

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
      "ghostty"
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
