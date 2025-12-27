{
  pkgs,
  perSystem,
  ...
}:
let
  nvim = perSystem.self.nvim;
in
pkgs.mkShellNoCC {
  packages = [
    pkgs.git
    pkgs.nixos-anywhere
    pkgs.nh
    perSystem.self.all
    perSystem.self.ni
    nvim.neovim-nightly
  ]
  ++ nvim.tools;

  env = {
    EDITOR = "nvim";
    NVIM_APPNAME = "nvim-dev";
  };

  shellHook = ''
    ln -sfn "$(realpath ./home/nvim)" ~/.config/nvim-dev
  '';
}
