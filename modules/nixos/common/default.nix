{
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.firewall.allowPing = true;
  services.tailscale.openFirewall = true;
  services.tailscale.useRoutingFeatures = "both";
}
