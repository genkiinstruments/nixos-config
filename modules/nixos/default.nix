{ modulesPath, ... }:
{
  imports = [ "${modulesPath}/profiles/perlless.nix" ];

  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.firewall.allowPing = true;
  services.tailscale.openFirewall = true;
  services.tailscale.useRoutingFeatures = "both";
  systemd.services.tailscale.serviceConfig.TimeoutStopSec = 5; # Reduce the timeout from the default 90 seconds to something shorter
  systemd.services.tailscaled.restartIfChanged = false; # Prevent SSH disconnects during deploys over Tailscale
  users.users.root.initialHashedPassword = "$y$j9T$xA3OJK4WPx3Gu80.nTV6h/$DsBKf3OL11/d9bOAQmSVbgf2H2Ue4FAwhPLcatF0tX3";
}
