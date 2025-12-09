{
  environment.etc."ssh/ssh_config.d/secretive.conf".text = ''
    Host *
      IdentityAgent ~/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh
      ControlMaster auto
      ControlPersist 10m
      ControlPath ~/.ssh/sockets/%r@%h:%p
  '';

  homebrew = {
    enable = true;
    casks = [ "secretive" ];
  };
}
