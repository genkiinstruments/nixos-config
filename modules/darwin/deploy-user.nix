{
  ...
}:
{
  # Add x's host key to root authorized_keys for buildbot-effects deployment
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBBtnJ1eS+mI4EASAWk7NXin5Hln0ylYUPHe2ovQAa8G root@x"
  ];
}
