{
  pkgs,
  flake,
  inputs,
  perSystem,
  ...
}:
let
  # Build neovim nightly (0.12+) which has vim.pack support
  neovim-nightly = pkgs.neovim-unwrapped.overrideAttrs {
    version = "0.12.0-dev";
    src = inputs.neovim-nightly;
  };

  configDir = "${flake}/home/mvim-bundle";
in
pkgs.wrapNeovimUnstable neovim-nightly {
  luaRcContent = ''
    vim.opt.rtp:prepend("${configDir}")
    dofile("${configDir}/init.lua")
  '';
  vimAlias = true;
  viAlias = false;
  wrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    "${pkgs.lib.makeBinPath [
      pkgs.git
      pkgs.ripgrep
      pkgs.fd
      pkgs.fzf
      pkgs.nodejs
      pkgs.tree-sitter
      pkgs.nixfmt-rfc-style
      pkgs.nil
      pkgs.rust-analyzer
      pkgs.gopls
      pkgs.lua-language-server
      pkgs.nodePackages.typescript-language-server
      pkgs.nodePackages.vscode-langservers-extracted
      pkgs.pyright
      pkgs.ruff
      pkgs.stylua
      perSystem.expert.default
    ]}"
  ];
}
