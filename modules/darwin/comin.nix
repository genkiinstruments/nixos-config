{
  pkgs,
  config,
  inputs,
  flake,
  perSystem,
  ...
}:
let
  cfg = config.services.comin;
  cominConfigYaml = (pkgs.formats.yaml { }).generate "comin.yaml" {
    hostname = cfg.hostname;
    state_dir = "/var/lib/comin";
    remotes = cfg.remotes;
    exporter = cfg.exporter;
  };
in
{
  imports = [
    inputs.comin.darwinModules.comin
    flake.modules.shared.comin
  ];

  # Wrap comin with a buildbot check before running
  launchd.daemons.comin.serviceConfig.ProgramArguments = pkgs.lib.mkForce [
    "${pkgs.writeShellScript "comin-wrapper" ''
      # Query buildbot for running builds via Tailscale
      RUNNING=$(${pkgs.curl}/bin/curl -sf "http://x.tail01dbd.ts.net:8010/api/v2/builds?complete=false" | \
        ${pkgs.jq}/bin/jq '.builds | length' 2>/dev/null || echo "0")
      RUNNING=''${RUNNING:-0}

      if [ "$RUNNING" -gt 0 ]; then
        echo "Buildbot has $RUNNING running build(s), skipping comin switch"
        exit 0
      fi

      exec ${perSystem.comin.default}/bin/comin run --config ${cominConfigYaml}
    ''}"
  ];
}
