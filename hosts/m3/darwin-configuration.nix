{
  config,
  inputs,
  pkgs,
  flake,
  ...
}:
{
  imports = [
    inputs.srvos.darwinModules.desktop
    inputs.srvos.darwinModules.mixins-trusted-nix-caches
    inputs.agenix.darwinModules.default
    flake.modules.shared.default
    flake.modules.shared.home-manager
    flake.modules.shared.builders
    flake.modules.darwin.default
    flake.modules.darwin.secretive
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  genki.builders.builders = [
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

  age = {
    # Generate manually via `sudo ssh-keygen -A /etc/ssh/` on macOS, nixos use builtin /etc/ssh/ssh_host_ed25519_key
    identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets.atuin-key = {
      file = "${inputs.secrets}/atuin-key.age";
      mode = "644";
      owner = "olafur";
      group = "staff";
    };
  };

  home-manager.users.olafur.programs.atuin.settings.key_path = config.age.secrets.atuin-key.path;

  nix.settings.trusted-users = [ "olafur" ];
  system.primaryUser = "olafur";
  users.users.olafur = {
    isHidden = false;
    home = "/Users/olafur";
    shell = pkgs.fish;
  };

  # TODO: Failed to update: https://github.com/LnL7/nix-darwin/blob/a6746213b138fe7add88b19bafacd446de574ca7/modules/system/checks.nix#L93
  ids.gids.nixbld = 350;

  homebrew = {
    enable = true;
    casks = [
      # guis
      "raycast"
      "arc"
      "google-drive"
      "qlvideo" # video preview in macOS Finder
      "vlc"
    ];
    brews = [
      # clis and libraries
      "age-plugin-se"
    ];
    taps = [
      # for things not in the hombrew repo, e.g.,
    ];
    masApps = {
      # `nix run nixpkgs#mas -- search <app name>`
      Keynote = 409183694;
      Numbers = 409203825;
      WhatsApp = 310633997;
    };
  };
}
