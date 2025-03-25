{ }:
{
  nix = {
    sshServe.protocol = "ssh-ng";
    sshServe.enable = true;
    sshServe.write = true;
    # Using Tailscale SSH for authentication so no need to store keys
    settings.trusted-users = [ "nix-ssh" ];
  };
}
