{
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
    inputs.comin.darwinModules.comin
    flake.modules.darwin.default
    flake.modules.shared.default
  ];
  networking.hostName = "gkr";

  nixpkgs.hostPlatform = "aarch64-darwin";

  # Generate manually via `sudo ssh-keygen -A /etc/ssh/` on macOS, using the host key for decryption
  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  system.primaryUser = "genki";
  users.users.genki = {
    shell = pkgs.fish;
    isHidden = false;
    home = "/Users/genki";
    openssh.authorizedKeys.keyFiles = [ "${flake}/authorized_keys" ];
  };
  nix.settings.trusted-users = [
    "genki"
    "nix-ssh"
  ];
  environment.systemPackages = with pkgs; [
    openssh # needed for fido2 support
    gh # needed for the softwave github run
    neofetch
  ];
  programs.fish.enable = true; # Otherwise our shell won't be installed correctly

  # Create the nix-ssh user for remote builds - rely on Tailscale SSH for authentication
  # NOTE: Have to manually create the user on macOS. Does not need to be an administrator
  users.users.nix-ssh = {
    shell = pkgs.bash;
    isHidden = false;
    home = "/Users/nix-ssh";
    createHome = true;
  };

  # TODO: Failed to update: https://github.com/LnL7/nix-darwin/blob/a6746213b138fe7add88b19bafacd446de574ca7/modules/system/checks.nix#L93
  ids.gids.nixbld = 350;

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
}
