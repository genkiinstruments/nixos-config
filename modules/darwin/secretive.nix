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
    mkdir -p /var/run/secretive
    ln -sfn ${userSocketPath} ${sharedSocketPath}

    # Create SSH control socket directory with correct ownership
    install -d -o ${user} -m 700 /Users/${user}/.ssh/sockets
  '';

  homebrew = {
    enable = true;
    casks = [ "secretive" ];
  };
}
