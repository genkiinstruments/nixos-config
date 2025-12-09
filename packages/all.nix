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

  mkMprocsCmd = hosts: builtins.concatStringsSep " \\\n      " (
    map (h: ''"ssh -At root@${h}.${domain} '$REMOTE_PATH $CMD; exec bash'"'') hosts
  );
in
pkgs.writeShellApplication {
  name = pname;
  runtimeInputs = with pkgs; [
    mprocs
    openssh
  ];
  text = ''
    usage() {
      echo "Usage: all [--nixos|--darwin] <command>"
      echo "Runs <command> on hosts in parallel using mprocs"
      echo ""
      echo "Options:"
      echo "  --nixos   Only run on NixOS hosts: ${builtins.concatStringsSep ", " nixosHosts}"
      echo "  --darwin  Only run on Darwin hosts: ${builtins.concatStringsSep ", " darwinHosts}"
      echo "  (default) Run on all hosts"
      echo ""
      echo "Examples:"
      echo "  all 'comin status'"
      echo "  all --nixos 'nixos-rebuild switch --flake github:genkiinstruments/nixos-config'"
      echo "  all uptime"
      exit 1
    }

    if [ $# -eq 0 ]; then
      usage
    fi

    REMOTE_PATH="PATH=/run/current-system/sw/bin:\$PATH"
    FILTER=""

    if [ "$1" = "--nixos" ]; then
      FILTER="nixos"
      shift
    elif [ "$1" = "--darwin" ]; then
      FILTER="darwin"
      shift
    fi

    if [ $# -eq 0 ]; then
      usage
    fi

    CMD="$*"

    case "$FILTER" in
      nixos)
        mprocs \
          ${mkMprocsCmd nixosHosts}
        ;;
      darwin)
        mprocs \
          ${mkMprocsCmd darwinHosts}
        ;;
      *)
        mprocs \
          ${mkMprocsCmd allHosts}
        ;;
    esac
  '';
}
