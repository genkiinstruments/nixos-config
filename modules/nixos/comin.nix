{
  pkgs,
  inputs,
  flake,
  ...
}:
{
  imports = [
    inputs.comin.nixosModules.comin
    flake.modules.shared.comin
  ];

  systemd.services.comin.serviceConfig.ExecCondition =
    let
      checkScript = pkgs.writeShellScript "check-buildbot" /* bash */ ''
        # Query buildbot for running builds via Tailscale
        RUNNING=$(${pkgs.curl}/bin/curl -sf "http://x.tail01dbd.ts.net:8010/api/v2/builds?complete=false" | \
          ${pkgs.jq}/bin/jq '.builds | length' 2>/dev/null || echo "0")
        RUNNING=''${RUNNING:-0}

        if [ "$RUNNING" -gt 0 ]; then
          echo "Buildbot has $RUNNING running build(s), skipping comin switch"
          exit 1
        fi
        exit 0
      '';
    in
    "${checkScript}";
}
