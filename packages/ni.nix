{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "ni";
  runtimeInputs = with pkgs; [
    pkgs.fzf
    nix-search-tv
  ];
  # prevent IFD, thanks @Michael-C-Buckley
  text = ''exec "${pkgs.nix-search-tv.src}/nixpkgs.sh" "$@"'';
}
