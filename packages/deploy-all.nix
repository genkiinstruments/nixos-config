{
  pkgs,
  pname,
  ...
}:
pkgs.writeShellApplication {
  name = pname;
  runtimeInputs = with pkgs; [
    mprocs
    openssh
  ];
  text = ''
    FLAKE="github:genkiinstruments/nixos-config"

    mprocs \
      "ssh -At root@x.tail01dbd.ts.net 'nixos-rebuild switch --flake $FLAKE; nix run nixpkgs#btop'" \
      "ssh -At root@m2.tail01dbd.ts.net 'nixos-rebuild switch --flake $FLAKE; nix run nixpkgs#btop'" \
      "ssh -At root@gdrn.tail01dbd.ts.net 'nixos-rebuild switch --flake $FLAKE; nix run nixpkgs#btop'" \
      "ssh -At root@g.tail01dbd.ts.net 'nixos-rebuild switch --flake $FLAKE; nix run nixpkgs#btop'" \
      "ssh -At root@pbt.tail01dbd.ts.net 'nixos-rebuild switch --flake $FLAKE; nix run nixpkgs#btop'" \
      "ssh -At root@joip.tail01dbd.ts.net 'nixos-rebuild switch --flake $FLAKE; nix run nixpkgs#btop'" \
      "ssh -At root@gkr.tail01dbd.ts.net '/run/current-system/sw/bin/darwin-rebuild switch --flake $FLAKE; nix run nixpkgs#btop'" 
    # "sudo /run/current-system/sw/bin/darwin-rebuild switch --flake $FLAKE; nix run nixpkgs#btop"
  '';
}
