{
  config,
  lib,
  ...
}:
let
  cfg = config.services.monitoring;
in
{
  options.services.monitoring = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Prometheus and Grafana monitoring stack";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = "genki.is";
      description = "Domain for monitoring services";
    };

    prometheusPort = lib.mkOption {
      type = lib.types.int;
      default = 9090;
      description = "Port for Prometheus";
    };

    grafanaPort = lib.mkOption {
      type = lib.types.int;
      default = 3000;
      description = "Port for Grafana";
    };
  };

  config = lib.mkIf cfg.enable {
    # Prometheus configuration
    services.prometheus = {
      enable = true;
      port = cfg.prometheusPort;

      globalConfig = {
        scrape_interval = "15s";
        evaluation_interval = "15s";
      };

      scrapeConfigs = [
        {
          job_name = "systemd";
          static_configs = [
            {
              targets = [ "localhost:9558" ];
              labels.instance = "gdrn";
            }
            {
              targets = [ "x.tail01dbd.ts.net:9558" ];
              labels.instance = "x";
            }
            {
              targets = [ "kroli.tail01dbd.ts.net:9558" ];
              labels.instance = "kroli";
            }
            {
              targets = [ "v1.tail01dbd.ts.net:9558" ];
              labels.instance = "v1";
            }
            {
              targets = [ "pbt.tail01dbd.ts.net:9558" ];
              labels.instance = "pbt";
            }
          ];
        }
        {
          job_name = "comin";
          static_configs = [
            {
              targets = [ "localhost:4243" ];
              labels.instance = "gdrn";
            }
            {
              targets = [ "x.tail01dbd.ts.net:4243" ];
              labels.instance = "x";
            }
            {
              targets = [ "kroli.tail01dbd.ts.net:4243" ];
              labels.instance = "kroli";
            }
            {
              targets = [ "v1.tail01dbd.ts.net:4243" ];
              labels.instance = "v1";
            }
            {
              targets = [ "pbt.tail01dbd.ts.net:4243" ];
              labels.instance = "pbt";
            }
          ];
        }
      ];
    };

    # Grafana configuration
    services.grafana = {
      enable = true;
      settings = {
        server = {
          http_addr = "127.0.0.1";
          http_port = cfg.grafanaPort;
          domain = "grafana.${cfg.domain}";
        };
        analytics.reporting_enabled = false;
        "auth.anonymous" = {
          enabled = true;
          org_role = "Viewer";
        };
      };

      provision = {
        enable = true;

        datasources.settings.datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            url = "http://localhost:${toString cfg.prometheusPort}";
            isDefault = true;
          }
        ];

        dashboards.settings.providers = [ ];
      };
    };

    # Systemd exporter
    services.prometheus.exporters.systemd = {
      enable = true;
      port = 9558;
      extraFlags = [
        "--collector.enable-ip-accounting"
        "--collector.enable-restart-count"
      ];
    };

    # Open firewall for exporters (only on tailnet)
    networking.firewall.interfaces."tailscale0" = {
      allowedTCPPorts = [
        9558 # systemd exporter
        4243 # comin exporter
      ];
    };

    # Caddy reverse proxy
    services.caddy.virtualHosts."prometheus.${cfg.domain}" = {
      extraConfig = ''
        reverse_proxy localhost:${toString cfg.prometheusPort}
      '';
    };

    services.caddy.virtualHosts."grafana.${cfg.domain}" = {
      extraConfig = ''
        reverse_proxy localhost:${toString cfg.grafanaPort}
      '';
    };
  };
}
