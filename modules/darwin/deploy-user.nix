{
  ...
}:
{
  # Add x's host key to nix-ssh authorized_keys for buildbot-effects deployment
  users.users.nix-ssh.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBBtnJ1eS+mI4EASAWk7NXin5Hln0ylYUPHe2ovQAa8G root@x"
  ];

  # Trust nix-ssh for remote nix operations
  nix.settings.trusted-users = [ "nix-ssh" ];

  # Passwordless sudo for deployment commands
  environment.etc."sudoers.d/nix-ssh-deploy".text = ''
    nix-ssh ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/darwin-rebuild
  '';
}
