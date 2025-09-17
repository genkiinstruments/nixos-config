{
  flake,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.srvos.darwinModules.desktop
    inputs.srvos.darwinModules.mixins-terminfo
    inputs.srvos.darwinModules.mixins-trusted-nix-caches
    flake.modules.darwin.default
    flake.modules.darwin.secretive
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

  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "pbt";
        systems = [ "aarch64-linux" ];
        maxJobs = 8;
        sshUser = "nix-ssh";
        protocol = "ssh-ng";
        supportedFeatures = [
          "nixos-test"
          "benchmark"
          "big-parallel"
          "kvm"
        ];
      }
    ];
  };

  programs.ssh.extraConfig = ''
    Host pbt pbt.tail01dbd.ts.net
      User nix-ssh
      HostName pbt.tail01dbd.ts.net
      StrictHostKeyChecking accept-new
      BatchMode yes
      PubkeyAuthentication yes
      IdentitiesOnly yes
  '';

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
