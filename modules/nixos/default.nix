{
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.firewall.allowPing = true;
  services.tailscale.openFirewall = true;
  services.tailscale.useRoutingFeatures = "both";
  systemd.services.tailscale.serviceConfig.TimeoutStopSec = 5; # Reduce the timeout from the default 90 seconds to something shorter
  users.users.root.initialHashedPassword = "$y$j9T$xA3OJK4WPx3Gu80.nTV6h/$DsBKf3OL11/d9bOAQmSVbgf2H2Ue4FAwhPLcatF0tX3";
}
