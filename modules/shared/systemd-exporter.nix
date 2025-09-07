{ lib, pkgs, ... }:
{
  # Enable systemd exporter on all NixOS systems
  config = lib.mkIf (pkgs.stdenv.isLinux) {
    services.prometheus.exporters.systemd = {
      enable = true;
      port = 9558;
      extraFlags = [
        "--collector.enable-ip-accounting"
        "--collector.enable-restart-count"
      ];
    };

    # Open firewall only on tailscale interface
    networking.firewall.interfaces."tailscale0" = {
      allowedTCPPorts = [ 9558 ];
    };
  };
}
