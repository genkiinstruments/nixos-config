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
    flake.darwinModules.common
    flake.modules.shared.default
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  # Generate manually via `sudo ssh-keygen -A /etc/ssh/` on macOS, using the host key for decryption
  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  users.users.genki = {
    shell = pkgs.fish;
    isHidden = false;
    home = "/Users/genki";
    openssh.authorizedKeys.keyFiles = [ "${flake}/authorized_keys" ];
  };
  environment.systemPackages = with pkgs; [ openssh ]; # needed for fido2 support
  programs.fish.enable = true; # Otherwise our shell won't be installed correctly

  nix.settings.trusted-users = [
    "genki"
    "nix-ssh"
    "root"
  ];

  # Create the nix-ssh user for remote builds - rely on Tailscale SSH for authentication
  users.users.nix-ssh = {
    name = "nix-ssh";
    shell = pkgs.bash;
    # Basic user with nix access - no need for SSH keys since we use Tailscale
    isHidden = false;
    home = "/Users/Shared/nix-ssh";
    createHome = true;
    # Explicitly set UID for better compatibility
    uid = 599;
    gid = 20; # staff group
  };

  # Make sure the home directory has proper permissions
  system.activationScripts.postActivation.text = ''
    # Ensure the nix-ssh user has a proper home directory and SSH setup
    mkdir -p /Users/Shared/nix-ssh
    mkdir -p /Users/Shared/nix-ssh/bin

    # Create an executable wrapper script for SSH commands that sets PATH
    cat > /Users/Shared/nix-ssh/bin/nix-ssh-wrapper.sh << 'EOF'
#!/bin/bash
export PATH=/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:$PATH
exec "$@"
EOF
    chmod +x /Users/Shared/nix-ssh/bin/nix-ssh-wrapper.sh

    # Set up proper PATH for nix-ssh to find nix commands
    cat > /Users/Shared/nix-ssh/.bash_profile << 'EOF'
export PATH=/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:$PATH
export NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
EOF

    # Change SSH shell command for nix-ssh user to use the wrapper
    dscl . -change /Users/nix-ssh UserShell /bin/bash /Users/Shared/nix-ssh/bin/nix-ssh-wrapper.sh || true

    # Fix ownerships
    chown -R nix-ssh:staff /Users/Shared/nix-ssh
    
    # Add nix-ssh to nixbld group for build permissions
    dscl . -append /Groups/nixbld GroupMembership nix-ssh || true
  '';

  # Enable Tailscale
  services.tailscale.enable = true;

  # Enable remote builds
  nix.distributedBuilds = true;

  # Configure Nix for serving builds
  nix.extraOptions = ''
    # Enable better protocol for SSH
    builders-use-substitutes = true
    experimental-features = nix-command flakes
  '';

  # Make sure all required groups exist
  users.groups.nixbld = { };
  users.knownGroups = [ "nixbld" ];

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
