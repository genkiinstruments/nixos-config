_: {
  environment.etc."ssh/ssh_config.d/secretive.conf".text = ''
    Host *
      # Secretive SSH agent socket
      IdentityAgent ~/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh

      # Enable ControlMaster with persistent connections
      # After one authentication, reuse the connection for 10 minutes
      # This reduces the need for repeated Touch ID confirmations
      ControlMaster auto
      ControlPath none
      ControlPersist 30m

      # Forward agent to remote hosts
      ForwardAgent yes

      # Automatically add keys to the agent
      AddKeysToAgent yes

      # Accept new host keys automatically (warn on changes)
      StrictHostKeyChecking accept-new
  '';

  homebrew = {
    enable = true;
    casks = [ "secretive" ];
  };
}
