{
  config,
  lib,
  ...
}:
let
  cfg = config.services.cloudflared;
  tunnelIds = lib.attrNames cfg.tunnels;
in
{
  config = lib.mkIf (cfg.enable && tunnelIds != [ ]) {
    systemd.services = lib.listToAttrs (
      map (id: {
        name = "cloudflared-tunnel-${id}";
        value = {
          after = [
            "network-online.target"
            "nss-lookup.target"
          ];
          wants = [ "network-online.target" ];
          serviceConfig = {
            Restart = "on-failure";
            RestartSec = "5s";
          };
        };
      }) tunnelIds
    );
  };
}
