{ pkgs, ... }:
{
  systemd.services.comin.serviceConfig.ExecCondition =
    let
      checkScript = pkgs.writeShellScript "check-buildbot" ''
        # Query buildbot for running builds
        RUNNING=$(${pkgs.curl}/bin/curl -s "http://buildbot.genki.is/api/v2/builds?complete=false" | \
          ${pkgs.jq}/bin/jq '.builds | length')

        if [ "$RUNNING" -gt 0 ]; then
          echo "Buildbot has $RUNNING running build(s), skipping comin switch"
          exit 1
        fi
        exit 0
      '';
    in
    "${checkScript}";
}
