{ pkgs, ... }:
pkgs.writeShellScriptBin "bootstrap-dotfiles" ''
  set -x
  export PATH=${
    pkgs.lib.makeBinPath [
      pkgs.gitMinimal
      pkgs.coreutils
      pkgs.findutils
      pkgs.nix
      pkgs.jq
      pkgs.bash
    ]
  }
  if [ ! -d "$HOME/.homesick/repos/homeshick" ]; then
    git clone --depth=1 https://github.com/andsens/homeshick.git "$HOME/.homesick/repos/homeshick"
  fi
  if [ ! -d "$HOME/.homesick/repos/dotfiles" ]; then
    "$HOME/.homesick/repos/homeshick/bin/homeshick" clone https://github.com/multivac61/nixos-config.git
  fi
  "$HOME/.homesick/repos/homeshick/bin/homeshick" symlink
''
