{
  networking.firewall.interfaces.ygg0.allowedTCPPorts = [ 22 ];

  services.yggdrasil = {
    enable = true;
    openMulticastPort = true;
    persistentKeys = true;
    settings = {
      "Peers" = [
        "tls://bidstonobservatory.org:993"
        "tls://uk1.servers.devices.cwinfo.net:28395"
        "tls://51.38.64.12:28395"
        "tcp://88.210.3.30:65533"
        "tcp://s2.i2pd.xyz:39565"
        "tcp://s-kzn-0.sergeysedoy97.ru:65533"
        "tls://supergay.network:443"
      ];
      "MulticastInterfaces" = [
        {
          "Regex" = "w.*";
          "Beacon" = true;
          "Listen" = true;
          "Port" = 9001;
          "Priority" = 0;
        }
      ];
      "AllowedPublicKeys" = [ ];
      "IfName" = "auto";
      "IfMTU" = 65535;
      "NodeInfoPrivacy" = false;
      "NodeInfo" = null;
    };
  };
}
