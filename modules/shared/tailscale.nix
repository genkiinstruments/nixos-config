_: {
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    openFirewall = true;
    permitCertUid = "caddy";
  };

  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
