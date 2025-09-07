{ lib, config, ... }:
{
  # Enable comin exporter if comin is enabled
  config = lib.mkIf (config.services.comin.enable or false) {
    services.comin.exporter = {
      port = 4243;
      openFirewall = false; # We'll handle this via tailscale interface
    };

    # Open firewall only on tailscale interface
    networking.firewall.interfaces."tailscale0" = {
      allowedTCPPorts = [ 4243 ];
    };
  };
}
