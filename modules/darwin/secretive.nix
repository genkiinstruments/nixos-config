_: {
  environment.etc."ssh/ssh_config.d/secretive.conf".text = ''
    # GitHub hosts - use ControlMaster for reduced Touch ID prompts
    Host github.com *.github.com
      # Secretive SSH agent socket
      IdentityAgent ~/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh

      # Enable ControlMaster with persistent connections
      # After one authentication, reuse the connection for 10 minutes
      # This reduces the need for repeated Touch ID confirmations
      ControlMaster auto
      ControlPath ~/.ssh/master-%r@%n:%p
      ControlPersist 1h

      # Automatically add keys to the agent
      AddKeysToAgent yes

    # All other hosts - no ControlMaster for better interactive sessions
    Host *
      IdentityAgent ~/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh
      ForwardAgent yes
      AddKeysToAgent yes
  '';

  homebrew = {
    enable = true;
    casks = [ "secretive" ];
  };
}
