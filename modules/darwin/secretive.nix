_: {
  environment.etc."ssh/ssh_config.d/secretive.conf".text = ''
    Host *
      IdentityAgent ~/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh
  '';

  homebrew = {
    enable = true;
    casks = [ "secretive" ];
  };
}
