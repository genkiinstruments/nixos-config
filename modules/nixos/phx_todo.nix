{
  pkgs,
  lib,
  config,
  perSystem,
  ...
}:
with lib;
let
  cfg = config.services.phx_todo;
in
{
  options.services.phx_todo = {
    enable = mkEnableOption "Phoenix phx_todo service";

    package = mkPackageOption perSystem.self "phx_todo" { };

    port = mkOption {
      type = types.port;
      default = 4000;
      description = "Port to run the Phoenix application on";
    };

    secretKeybaseFile = mkOption {
      type = types.either types.path types.str;
      description = ''
        The secret key base is used to sign/encrypt cookies and other secrets.
        A default value is used in config/dev.exs and config/test.exs but you
        want to use a different value for prod and you most likely don't want
        to check this value into version control.
        You can generate one by calling: mix phx.gen.secret
      '';
    };

    url = mkOption {
      default = "http://localhost:4000";
      type = types.str;
      description = ''
        The URL where `phx_todo` is accessible
      '';
    };

    postgres = {
      enable = mkEnableOption "creating a postgresql instance" // {
        default = true;
      };
      dbname = mkOption {
        default = "phx_todo";
        type = types.str;
        description = ''
          Name of the database to use.
        '';
      };
      user = mkOption {
        default = "phx_todo";
        type = types.str;
        description = ''
          User of the database to use.
        '';
      };
      password = mkOption {
        default = "phx_todo";
        type = types.str;
        description = ''
          Password of the database to use.
        '';
      };
      socket = mkOption {
        default = "/run/postgresql";
        type = types.str;
        description = ''
          Path to the UNIX domain-socket to communicate with `postgres`.
        '';
      };
    };

    tailscale.enable = mkEnableOption "create tailscale funnel" // {
      default = true;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.phx_todo = {
      description = "Phoenix Application Service";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network.target"
        "postgresql.service"
        "phx_todo-postgres.service" # Depend on the postgres setup service
      ];
      requires = [ "phx_todo-postgres.service" ]; # Ensure postgres setup runs before
      environment = {
        PORT = toString cfg.port;
        PHX_HOST = cfg.url;

        DATABASE_URL = "postgresql://${cfg.postgres.user}:${cfg.postgres.password}@localhost/${cfg.postgres.dbname}?host=${cfg.postgres.socket}";
        TZDATA_DIR = "/var/lib/phx_todo/elixir_tzdata"; # Ensure that `tzdata` doesn't write into its store-path

        # When distribution is enabled,
        # Elixir spwans the Erlang VM, which will listen by default on all
        # interfaces for messages between Erlang nodes (capable of
        # remote code execution); it can be protected by a cookie; see
        # https://erlang.org/doc/reference_manual/distributed.html#security).
        # We disable it.
        RELEASE_DISTRIBUTION = "none";
        # Additional safeguard, in case `RELEASE_DISTRIBUTION=none` ever
        # stops disabling the start of EPMD.
        ERL_EPMD_ADDRESS = "127.0.0.1";
      };
      serviceConfig = {
        DynamicUser = true;
        PrivateTmp = true;
        Restart = "on-failure";
        WorkingDirectory = "/var/lib/phx_todo";
        StateDirectory = "phx_todo";
        LoadCredential = [ "SECRET_KEY_BASE:${cfg.secretKeybaseFile}" ];
      };
      script = ''
        # Elixir does not start up if `RELEASE_COOKIE` is not set,
        # even though we set `RELEASE_DISTRIBUTION=none` so the cookie should be unused.
        # Thus, make a random one, which should then be ignored.
        export RELEASE_COOKIE=$(tr -dc A-Za-z0-9 < /dev/urandom | head -c 20)
        export SECRET_KEY_BASE="$(< $CREDENTIALS_DIRECTORY/SECRET_KEY_BASE )"

        ${cfg.package}/bin/migrate
        ${cfg.package}/bin/server
      '';
    };
    systemd.services.phx_todo-postgres = lib.mkIf cfg.postgres.enable {
      description = "Create PostgreSQL user and database for phx_todo";
      after = [ "postgresql.service" ];
      before = [ "phx_todo.service" ]; # Create postgres user/db before phx_todo starts
      partOf = [ "phx_todo.service" ];
      wantedBy = [ "multi-user.target" ]; # Ensure the service is enabled
      serviceConfig = {
        Type = "oneshot";
        User = config.services.postgresql.superUser;
        RemainAfterExit = true;
      };
      script = with cfg.postgres; ''
        set -e # Exit immediately if a command exits with a non-zero status.
        PSQL() {
          ${config.services.postgresql.package}/bin/psql --port=5432 "$@"
        }
        # check if the database already exists
        if ! PSQL -lqt | ${pkgs.coreutils}/bin/cut -d \| -f 1 | ${pkgs.gnugrep}/bin/grep -qw ${dbname} ; then
          echo "Creating role ${user}"
          PSQL -tAc "CREATE ROLE ${user} WITH LOGIN PASSWORD '${password}';"
          echo "Creating database ${dbname}"
          PSQL -tAc "CREATE DATABASE ${dbname} WITH OWNER ${user};"
        else
          echo "Database ${dbname} already exists"
        fi
      '';
    };

    services.postgresql = lib.mkIf cfg.postgres.enable { enable = true; };

    services.tailscale = lib.mkIf cfg.tailscale.enable { enable = true; };

    systemd.services.tailscale-funnel-node-exporter = lib.mkIf cfg.tailscale.enable {
      description = "Tailscale Funnel live_media";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.tailscale}/bin/tailscale funnel 4000";
        Restart = "on-failure";
      };
      wantedBy = [ "multi-user.target" ];
    };

    # Enable Let's Encrypt and HTTPS by default.
    services.nginx.virtualHosts.${cfg.url} = {
      enableACME = true;
      forceSSL = true;
    };
  };
}
