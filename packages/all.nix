{
  pkgs,
  pname,
  flake,
  ...
}:
let
  nixosHosts = builtins.attrNames flake.nixosConfigurations;
  darwinHosts = builtins.attrNames flake.darwinConfigurations;
  allHosts = nixosHosts ++ darwinHosts;

  domain = "tail01dbd.ts.net";
in
pkgs.writeShellApplication {
  name = pname;
  runtimeInputs = with pkgs; [
    mprocs
    openssh
  ];
  text = /* bash */ ''
    usage() {
      echo "Usage: all [options] <command>"
      echo "Runs <command> on hosts in parallel using mprocs"
      echo ""
      echo "Options:"
      echo "  -h, --help           Show this help message"
      echo "  --hosts h1,h2,...    Specify hosts (comma-separated)"
      echo "  --nixos              Only run on NixOS hosts: ${builtins.concatStringsSep ", " nixosHosts}"
      echo "  --darwin             Only run on Darwin hosts: ${builtins.concatStringsSep ", " darwinHosts}"
      echo "  (default)            Run on all hosts"
      echo ""
      echo "Examples:"
      echo "  all 'comin status'"
      echo "  all --hosts kk uptime"
      echo "  all --nixos 'nixos-rebuild switch --flake github:genkiinstruments/nixos-config'"
      echo "  all uptime"
    }

    if [ $# -eq 0 ]; then
      usage
      exit 1
    fi

    REMOTE_PATH="PATH=/run/current-system/sw/bin:\$PATH"
    HOSTS=""
    FILTER=""

    while [ $# -gt 0 ]; do
      case "$1" in
        -h|--help)
          usage
          exit 0
          ;;
        --hosts)
          shift
          HOSTS="''${1//,/ }"
          shift
          ;;
        --nixos)
          FILTER="nixos"
          shift
          ;;
        --darwin)
          FILTER="darwin"
          shift
          ;;
        *)
          break
          ;;
      esac
    done

    if [ $# -eq 0 ]; then
      echo "Error: No command specified"
      usage
      exit 1
    fi

    CMD="$*"

    # Determine hosts
    if [ -z "$HOSTS" ]; then
      case "$FILTER" in
        nixos)
          HOSTS="${builtins.concatStringsSep " " nixosHosts}"
          ;;
        darwin)
          HOSTS="${builtins.concatStringsSep " " darwinHosts}"
          ;;
        *)
          HOSTS="${builtins.concatStringsSep " " allHosts}"
          ;;
      esac
    fi

    # Build mprocs arguments dynamically
    MPROCS_ARGS=()
    for h in $HOSTS; do
      MPROCS_ARGS+=("ssh -At root@$h.${domain} '$REMOTE_PATH $CMD; exec bash'")
    done

    exec mprocs "''${MPROCS_ARGS[@]}"
  '';
}
