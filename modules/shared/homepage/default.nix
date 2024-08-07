_: {
  imports = [ ./joip.nix ];

  services = {
    homepage-dashboard = {
      enable = true;
      openFirewall = true;
    };

    caddy = {
      enable = true;
      virtualHosts."joip.tail01dbd.ts.net".extraConfig = ''
        reverse_proxy http://localhost:8082
      '';
    };

    tailscale = {
      enable = true;
      openFirewall = true;
      useRoutingFeatures = "both";
      permitCertUid = "caddy";
    };

    resolved.enable = true;
  };
}
