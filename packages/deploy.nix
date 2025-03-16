{
  pkgs,
  inputs,
  ...
}:
let
  flakeInputs = map (v: v.outPath) (builtins.attrValues inputs.self.inputs);
in
pkgs.writeShellApplication {
  name = "deploy";
  runtimeInputs = with pkgs; [
    nix
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

    # Copy all flake inputs to the target using ssh-ng
    nix copy ${toString flakeInputs} --to ssh-ng://root@"$NAME"

    # Copy the flake itself using ssh-ng
    nix copy ${inputs.self} --to ssh-ng://root@"$NAME"

    # Run the appropriate rebuild command
    ssh -t "root@$NAME" "
      if [ -d /Applications ]; then
        # macOS
        chown -R $USER:staff /etc/nixos-config/home/nvim 2>/dev/null || true
        chmod -R u+w /etc/nixos-config/home/nvim 2>/dev/null || true
        darwin-rebuild switch --flake '${inputs.self}#$NAME'
      else
        # NixOS
        chown -R $USER:users /etc/nixos-config/home/nvim 2>/dev/null || true
        chmod -R u+w /etc/nixos-config/home/nvim 2>/dev/null || true
        nixos-rebuild switch --flake '${inputs.self}#$NAME'
      fi
    "
  '';
}
