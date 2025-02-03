{
  pkgs,
  ...
}:

let
  release = pkgs.callPackage ./phx_todo.nix { };
  release_name = "phx_todo";
  working_directory = "/var/lib/${release_name}";
in
{
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "postgres" ];
    authentication = pkgs.lib.mkForce ''
      # TYPE  DATABASE    USER    ADDRESS         METHOD
      # Allow local connections
      local   all        all                     trust
      local   oli        oli                     md5

      # IPv4 connections
      host    all        all     127.0.0.1/32    md5
      host    oli        oli     127.0.0.1/32    md5

      # IPv6 connections
      host    all        all     ::1/128         md5
      host    oli        oli     ::1/128         md5
    '';
    initialScript = pkgs.writeText "backend-initScript" ''
      CREATE ROLE oli WITH LOGIN PASSWORD 'oli' SUPERUSER;
      CREATE DATABASE oli;
      GRANT ALL PRIVILEGES ON DATABASE oli TO oli;
    '';
  };
  systemd.services.${release_name} = {
    wantedBy = [ "multi-user.target" ];
    after = [
      "network.target"
      "postgresql.service"
    ];
    requires = [
      "network-online.target"
      "postgresql.service"
    ];
    description = "phx_todo";
    environment = {
      RELEASE_TMP = working_directory;
      RELEASE_COOKIE = "my_cookie";
      DATABASE_URL = "postgresql://oli:oli@localhost/oli";
      SECRET_KEY_BASE = "42";
    };
    serviceConfig = {
      Type = "exec";
      DynamicUser = true;
      WorkingDirectory = working_directory;
      PrivateTmp = true;
      ExecStart = "${release}/bin/${release_name} start";
      ExecStop = "${release}/bin/${release_name} stop";
      ExecReload = "${release}/bin/${release_name} restart";
      Restart = "on-failure";
      RestartSec = 5;
      StartLimitBurst = 3;
      StartLimitIntervalSec = 10;
    };
    path = [ pkgs.bash ];
  };
  # in case you have migration scripts or you want to use a remote shell
  environment.systemPackages = [ release ];
}
