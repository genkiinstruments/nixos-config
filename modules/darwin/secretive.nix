{ config, ... }:
let
  user = config.system.primaryUser;
in
{
  environment.etc."ssh/ssh_config.d/secretive.conf".text = ''
    Host *
      IdentityAgent ~/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh
      ControlMaster auto
      ControlPersist 10m
      ControlPath ~/.ssh/sockets/%r@%h:%p
  '';

  system.activationScripts.postActivation.text = ''
    install -d -o ${user} -m 700 /Users/${user}/.ssh/sockets
  '';

  homebrew = {
    enable = true;
    casks = [ "secretive" ];
  };
}
