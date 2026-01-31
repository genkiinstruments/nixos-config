{
  ...
}:
{
  # Enable nix-ssh user for remote builds and deployment via nix.sshServe
  nix.sshServe.enable = true;
  nix.sshServe.write = true;

  # Add x's host key to nix-ssh authorized_keys for buildbot-effects deployment
  users.users.nix-ssh.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBBtnJ1eS+mI4EASAWk7NXin5Hln0ylYUPHe2ovQAa8G root@x"
  ];

  # Add nix-ssh to wheel group for sudo access (srvos enables execWheelOnly)
  users.users.nix-ssh.extraGroups = [ "wheel" ];

  # Trust nix-ssh for remote builds
  nix.settings.trusted-users = [ "nix-ssh" ];

  # Passwordless sudo for deployment commands (using wheel group to satisfy execWheelOnly)
  security.sudo.extraRules = [
    {
      groups = [ "wheel" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/nix/var/nix/profiles/system/bin/switch-to-configuration";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
