{ pkgs, ... }:
{
  services.comin = {
    enable = true;
    remotes = [
      {
        name = "origin";
        url = "https://github.com/genkiinstruments/nixos-config";
        branches.main.name = "main";
      }
    ];
  };

  systemd.services.comin.serviceConfig.ExecCondition =
    let
      checkScript = pkgs.writeShellScript "check-buildbot" ''
        # Query buildbot for running builds via Tailscale
        RUNNING=$(${pkgs.curl}/bin/curl -sf "http://x.tail01dbd.ts.net:8010/api/v2/builds?complete=false" | \
          ${pkgs.jq}/bin/jq '.builds | length' 2>/dev/null || echo "0")

        if [ "$RUNNING" -gt 0 ]; then
          echo "Buildbot has $RUNNING running build(s), skipping comin switch"
          exit 1
        fi
        exit 0
      '';
    in
    "${checkScript}";
}
