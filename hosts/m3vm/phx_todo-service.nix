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

    preBuild = ''
      # for external task you need a workaround for the no deps check flag
      # https://github.com/phoenixframework/phoenix/issues/2690
      mix do deps.loadpaths --no-deps-check, assets.deploy
      mix do deps.loadpaths --no-deps-check, phx.gen.release

      # Ensure that `tzdata` doesn't write into its store-path
      cat >> config/runtime.exs <<EOF
      config :tzdata, :data_dir, System.get_env("TZDATA_DIR")
      EOF
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
  };

  config = mkIf cfg.enable {
    systemd.services.${appName} =
      let
        passwd_set = "ALTER USER ${appName} PASSWORD '${appName}';";
      in
      {
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
          DATABASE_URL = "ecto://${appName}:${appName}@localhost/${appName}?host=/run/postgresql";
          SECRET_KEY_BASE = "4nWbhhSm37+ddeAPP62e1c4K4ckKxSPus5ct7frMz21MIjgl0bI+4/h2JECs7oGXy2";
          TZDATA_DIR = "/var/lib/${appName}/elixir_tzdata";
          PHX_HOST = "m3vm.tail01dbd.ts.net";
        };
        serviceConfig = {
          Type = "simple";
          ExecStart = "${phoenixRelease}/bin/server";
          ExecStartPre = pkgs.writeShellScript "${appName}-pre" ''
            ${pkgs.postgresql}/bin/psql -c "${passwd_set}"
            ${phoenixRelease}/bin/migrate
          '';
          Restart = "on-failure";
          StateDirectory = "${appName}";
          WorkingDirectory = "/var/lib/${appName}";
          User = "${appName}";
          Group = "${appName}";
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
    environment.systemPackages = [ phoenixRelease ];
    environment.variables = {
      RELEASE_NAME = appName;
      # Needed if you want to run the application outside systemd, perhaps it should be glued into the app?
      RELEASE_COOKIE = "my_cookie";
      SECRET_KEY_BASE = "nWbhhSm37+ddeAPP62e1c4K4ckKxSPus5ct7frMz21MIjgl0bI+4/h2JECs7oGXy";
      PHX_HOST = "m3vm.tail01dbd.ts.net";
    };
    users.users.${appName} = {
      isSystemUser = true;
      createHome = true;
      group = "${appName}";
    };
    users.groups.${appName} = { };
  };
}
