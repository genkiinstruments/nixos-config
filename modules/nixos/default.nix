{
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.firewall.allowPing = true;
  services.tailscale.openFirewall = true;
  services.tailscale.useRoutingFeatures = "both";
  systemd.services.tailscale.serviceConfig.TimeoutStopSec = 5; # Reduce the timeout from the default 90 seconds to something shorter
}
