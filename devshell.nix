{
  pkgs,
  perSystem,
  ...
}:
let
  nvim = perSystem.self.nvim;

  # Dev neovim: uses local config with Nix-provided parsers
  nvim-dev = pkgs.writeShellScriptBin "nvim" /* bash */ ''
    exec ${nvim.neovim-nightly}/bin/nvim \
      --cmd "lua vim.opt.rtp:prepend('${nvim.treesitterGrammars}')" \
      "$@"
  '';
in
pkgs.mkShellNoCC {
  packages = [
    pkgs.git
    pkgs.nixos-anywhere
    pkgs.nh
    perSystem.self.all
    perSystem.self.ni
    nvim-dev
  ]
  ++ nvim.tools;

  env = {
    EDITOR = "nvim";
    NVIM_APPNAME = "nvim-dev";
  };

  shellHook = /* bash */ ''
    ln -sfn "$(realpath ./home/nvim)" ~/.config/nvim-dev
  '';
}
