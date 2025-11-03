{
  pkgs,
}:
pkgs.mkShellNoCC {
  packages = with pkgs; [
    git
    nixos-anywhere
    nh
  ];

  env = { };

  shellHook = ''export EDITOR=nvim'';
}
