{ pkgs, flake, ... }:
pkgs.writeShellApplication {
  name = "deploy";
  runtimeInputs = with pkgs; [
    nix
    rsync
    openssh
  ];
  text = ''
    if [ -z "$1" ] || [ -z "$2" ]; then
      echo "Error: Please provide name and username"
      echo "Usage: deploy <name> <username>"
      exit 1
    fi

    NAME="$1"
    USER="$2"
    echo "Deploying $NAME for user $USER"

    rsync -av --delete "${toString flake}/" "root@$NAME:/etc/nixos-config"

    ssh -t "root@$NAME" "
      if [ -d /Applications ]; then
        # macOS
        chown -R $USER:staff /etc/nixos-config/home/nvim
        chmod -R u+w /etc/nixos-config/home/nvim
        nix run nixpkgs#darwin-rebuild -- switch --flake '/etc/nixos-config#$NAME'
      else
        # NixOS
        chown -R $USER:users /etc/nixos-config/home/nvim
        chmod -R u+w /etc/nixos-config/home/nvim
        nix run nixpkgs#nixos-rebuild -- switch --flake '/etc/nixos-config#$NAME'
      fi
    "
  '';
}
