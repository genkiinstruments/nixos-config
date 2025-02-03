{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.${appName};
  appName = "phx_todo";
  pname = "phx_todo";
  version = "0.0.1";
  src = pkgs.fetchFromGitHub {
    owner = "multivac61";
    repo = "phx_todo";
    rev = "df490ec4f979c0df5e663b1788f87318c92c76f1";
    hash = "sha256-fCk7jpUKFtDBd6Md47Jwh4pJE+bwHCFDtua5H6c3Q2U=";
  };
  phoenixRelease = pkgs.beamPackages.mixRelease {
    inherit pname version src;

    mixFodDeps = pkgs.beamPackages.fetchMixDeps {
      inherit version src pname;
      sha256 = "sha256-JYfNRnMsBxmGReB/RBzeKH7DPR90cBU0vcZpvz7C7c8=";
      buildInputs = [ ];
      propagatedBuildInputs = [ ];
    };
    preConfigure = ''
      substituteInPlace config/config.exs \
        --replace "config :tailwind," "config :tailwind, path: \"${pkgs.tailwindcss}/bin/tailwindcss\","\
        --replace "config :esbuild," "config :esbuild, path: \"${pkgs.esbuild}/bin/esbuild\", "
    '';

    postBuild = ''
      # for external task you need a workaround for the no deps check flag
      # https://github.com/phoenixframework/phoenix/issues/2690
      mix do deps.loadpaths --no-deps-check, assets.deploy
    '';
  };
in
{
  options.services.${appName} = {
    enable = mkEnableOption "Phoenix application service";
    port = mkOption {
      type = types.port;
      default = 4000;
      description = "Port to run the Phoenix application on";
    };
    user = mkOption {
      type = types.str;
      default = appName;
      description = "User to run the Phoenix application as";
    };
    group = mkOption {
      type = types.str;
      default = appName;
      description = "Group to run the Phoenix application as";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.${appName} = {
      description = "Phoenix Application Service";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network.target"
        "postgresql.service"
      ];
      environment = {
        PORT = toString cfg.port;
        RELEASE_NAME = appName;
        RELEASE_COOKIE = "my_cookie";
        DATABASE_URL = "postgresql:///${appName}:${appName}@${appName}?host=/run/postgresql";
        SECRET_KEY_BASE = "42";
      };
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${phoenixRelease}/bin/${appName} start";
        Restart = "on-failure";
      };
    };

    # PostgreSQL configuration
    services.postgresql = {
      enable = true;
      ensureDatabases = [ "${appName}" ];
      ensureUsers = [
        {
          name = "${appName}";
          ensureDBOwnership = true;
        }
      ];
    };
  };
}
