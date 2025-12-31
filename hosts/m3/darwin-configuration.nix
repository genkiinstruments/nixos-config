{
  config,
  inputs,
  flake,
  ...
}:
{
  imports = [
    inputs.srvos.darwinModules.desktop
    inputs.srvos.darwinModules.mixins-trusted-nix-caches
    inputs.stylix.darwinModules.stylix
    inputs.agenix.darwinModules.default
    flake.modules.shared.stylix
    flake.modules.shared.default
    flake.modules.shared.home-manager
    flake.modules.shared.builders
    flake.modules.darwin.default
    flake.modules.darwin.user
    flake.modules.darwin.secretive
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  genki.user = "olafur";

  genki.builders = [
    {
      hostName = "gdrn";
      system = "x86_64-linux";
      maxJobs = 13;
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
      owner = "${config.system.primaryUser}";
      group = "staff";
    };
  };

  home-manager.users.${config.system.primaryUser}.programs.atuin.settings.key_path =
    config.age.secrets.atuin-key.path;

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
