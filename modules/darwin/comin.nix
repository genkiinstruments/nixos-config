{
  pkgs,
  inputs,
  flake,
  perSystem,
  ...
}:
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

      if [ "$RUNNING" -gt 0 ]; then
        echo "Buildbot has $RUNNING running build(s), skipping comin switch"
        exit 0
      fi

      exec ${perSystem.comin.default}/bin/comin "$@"
    ''}"
  ];
}
