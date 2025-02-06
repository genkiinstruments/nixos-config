{
  inputs,
  flake,
  config,
  ...
}:
{
  imports = [
    inputs.srvos.nixosModules.hardware-hetzner-cloud
    inputs.srvos.nixosModules.server
    inputs.disko.nixosModules.disko
    inputs.agenix.nixosModules.default
    flake.modules.nixos.phx_todo
    ./disko.nix
  ];

  disko.devices.disk.main.device = "/dev/sda";

  services.phx_todo = {
    enable = true;
    url = "2-do.org";
    secretKeybaseFile = config.age.secrets.p1_phx_todo.path;
    tailscale.enable = false;
  };

  # Configure Let's Encrypt
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "genki@genkiinstruments.com";

  # Allow you to SSH to the servers as root
  users.users.root.openssh.authorizedKeys.keyFiles = [ "${flake}/authorized_keys" ];

  age.secrets.p1_phx_todo.file = "${inputs.secrets}/p1_phx_todo.age";
  age.secrets.p1_ssh_host_ed25519_key.file = "${inputs.secrets}/p1_ssh_host_ed25519_key.age";
  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  services.openssh.hostKeys = [
    {
      path = config.age.secrets.p1_ssh_host_ed25519_key.file;
      type = "ed25519";
    }
  ];

  # The machine architecture.
  nixpkgs.hostPlatform = "x86_64-linux";

  # The machine hostname.
  networking.hostName = "t1";

  # Needed because Hetzner Online doesn't provide RA. Replace the IPv6 with your own.
  systemd.network.networks."10-uplink".networkConfig.Address = "2a01:4f9:c013:4db::/64";

  # Used by NixOS to handle state changes.
  system.stateVersion = "24.05";
}
