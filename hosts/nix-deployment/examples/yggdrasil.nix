{ config, pkgs, lib, ... }:
{
  networking = {
    useNetworkd = true;
    firewall.allowedTCPPorts = [ 9001 ];
  };
  services.yggdrasil = {
    enable = true;
    openMulticastPort = true;
    persistentKeys = true;
    settings = {
      "Peers" = [
        "tls://uk1.servers.devices.cwinfo.net:28395"
        "tls://51.38.64.12:28395"
        "tcp://88.210.3.30:65533"
        "tcp://s2.i2pd.xyz:39565"
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
  systemd.services.radvd = {
    after = [ "yggdrasil.service" ];
    serviceConfig = {
      ExecStart = lib.mkForce "@${config.services.radvd.package}/bin/radvd radvd -n -u radvd -C /run/radvd-config";
      ExecStartPre =
        let
          script = pkgs.writeShellScript "f" ''
            SUBNET=$(${pkgs.yggdrasil}/bin/yggdrasilctl -json getSelf | ${pkgs.jq}/bin/jq .subnet -r)
            cp --no-preserve=mode ${builtins.toFile "conf" config.services.radvd.config} /run/radvd-config
            sed "s,@YGGDRASIL_PREFIX@,$SUBNET,g" -i /run/radvd-config
          '';
        in
        "+${script}";
    };
  };
  services.radvd = {
    enable = true;
    config = ''
      interface wlan0
      {
           AdvSendAdvert on;
           prefix @YGGDRASIL_PREFIX@ {
               AdvOnLink on;
               AdvAutonomous on;
           };
           route 200::/7 {};
      };
      interface end0
      {
           AdvSendAdvert on;
           prefix @YGGDRASIL_PREFIX@ {
               AdvOnLink on;
               AdvAutonomous on;
           };
           route 200::/7 {};
      };
    '';
  };
  boot.kernel.sysctl = {
    # Enable IPv6 forwarding
    "net.ipv6.conf.all.forwarding" = "1";
  };

  environment.interactiveShellInit = /* bash */ ''
    (
    # Reset colors
    CO='\033[0m'

    # Colors
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    PURPLE='\033[0;35m'
    CYAN='\033[0;36m'
    WHITE='\033[0;37m'

    # Bold colors
    BBLACK='\033[1;30m'
    BRED='\033[1;31m'
    BGREEN='\033[1;32m'
    BYELLOW='\033[1;33m'
    BBLUE='\033[1;34m'
    BPURPLE='\033[1;35m'
    BCYAN='\033[1;36m'
    BWHITE='\033[1;37m'

    # Color accent to use in any primary text
    CA=$PURPLE
    CAB=$BPURPLE

    ${pkgs.coreutils}/bin/echo
    ${pkgs.coreutils}/bin/echo -e " █ ''${BGREEN}(✓)''${CO} ''${BWHITE}You are using a genuine Genki(TM) system.''${CO}"
    ${pkgs.coreutils}/bin/echo -e " █ Your Yggdrasil IPv6 Address is displayed as a QR Code below"
    ${pkgs.coreutils}/bin/echo -e ""
    ${pkgs.coreutils}/bin/echo -e ""
    ${pkgs.nettools}/bin/ifconfig/bin/ifconfig tun0 | ${pkgs.coreutils}/bin/grep -oP 'inet6\s+\K[0-9a-fA-F:]+' | ${pkgs.coreutils}/bin/grep -v 'fe80' | ${pkgs.qrencode}/bin/qrencode -t ANSIUTF8
    )
  '';
}


