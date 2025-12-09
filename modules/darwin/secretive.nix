{ config, ... }:
let
  user = config.system.primaryUser;
  userSocketPath = "/Users/${user}/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";
  sharedSocketPath = "/var/run/secretive/agent.sock";
in
{
  environment.etc."ssh/ssh_config.d/secretive.conf".text = ''
    Host *
      IdentityAgent ${sharedSocketPath}
      ControlMaster auto
      ControlPersist 10m
      ControlPath ~/.ssh/sockets/%r@%h:%p
  '';

  # Create symlink to Secretive socket accessible by nix-daemon
  system.activationScripts.postActivation.text = ''
    mkdir -p /var/run/secretive ~/.ssh/sockets
    ln -sfn ${userSocketPath} ${sharedSocketPath}
  '';

  homebrew = {
    enable = true;
    casks = [ "secretive" ];
  };
}
