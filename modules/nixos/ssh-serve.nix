_: {
  nix = {
    sshServe.protocol = "ssh-ng";
    sshServe.enable = true;
    sshServe.write = true;
    sshServe.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC/HMAT/nOa8F5LrFebnG7wk1o/K0Rx1HdDoFYxvLSef root@p4" # matt
    ];
    # Using Tailscale SSH for authentication so no need to store keys
    settings.trusted-users = [ "nix-ssh" ];
  };
}
