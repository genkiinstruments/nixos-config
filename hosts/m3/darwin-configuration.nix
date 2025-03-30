{
  config,
  inputs,
  pkgs,
  flake,
  ...
}:
{
  imports = [
    inputs.srvos.darwinModules.common
    inputs.srvos.darwinModules.mixins-terminfo
    inputs.agenix.darwinModules.default
    flake.modules.shared.default
    flake.modules.shared.home-manager
    flake.darwinModules.common
    flake.modules.shared.builders
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  age = {
    # Generate manually via `sudo ssh-keygen -A /etc/ssh/` on macOS, nixos use builtin /etc/ssh/ssh_host_ed25519_key
    identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets = {
      atuin-key = {
        file = "${inputs.secrets}/atuin-key.age";
        mode = "644";
        owner = "olafur";
        group = "staff";
      };
      cachix_auth_token = {
        file = "${inputs.secrets}/m3-CACHIX_AUTH_TOKEN.age";
        mode = "644";
        owner = "olafur";
        group = "staff";
      };
    };
  };

  home-manager.users.olafur.programs.atuin.settings.key_path = config.age.secrets.atuin-key.path;

  users.users.olafur = {
    isHidden = false;
    home = "/Users/olafur";
    shell = pkgs.fish;
  };
  nix.settings.trusted-users = [ "olafur" ];

  environment.systemPackages = with pkgs; [
    openssh # needed for fido2 support
  ];
  environment.variables.SSH_ASKPASS = "/Applications/ssh-askpass.app/Contents/MacOS/ssh-askpass"; # TODO: nixpkgs
  environment.variables.DISPLAY = ":0";

  environment.interactiveShellInit = ''
    export CACHIX_AUTH_TOKEN="$(cat ${config.age.secrets.cachix_auth_token.path})"
  '';
  # TODO: Failed to update: https://github.com/LnL7/nix-darwin/blob/a6746213b138fe7add88b19bafacd446de574ca7/modules/system/checks.nix#L93
  ids.gids.nixbld = 350;

  homebrew = {
    enable = true;
    casks = [
      # guis
      "shortcat"
      "raycast"
      "arc"
      "firefox"
    ];
    brews = [
      # clis and libraries
      "theseal/ssh-askpass/ssh-askpass"
    ];
    taps = [
      {
        name = "theseal/ssh-askpass";
        clone_target = "https://github.com/theseal/ssh-askpass.git";
        force_auto_update = true;
      }
    ];
    masApps = {
      # `nix run nixpkgs#mas -- search <app name>`
      "Keynote" = 409183694;
      "ColorSlurp" = 1287239339;
      "Numbers" = 409203825;
    };
  };
}
