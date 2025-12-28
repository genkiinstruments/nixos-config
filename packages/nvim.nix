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

  configDir = "${flake}/home/nvim";

  # All treesitter grammars (parsers + queries) bundled via Nix
  treesitterGrammars =
    let
      ts = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
    in
    pkgs.symlinkJoin {
      name = "treesitter-grammars";
      paths = [ ts ] ++ ts.passthru.dependencies;
    };

  tools = [
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
  ];

  wrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    "${pkgs.lib.makeBinPath tools}"
  ];

  wrapped = pkgs.wrapNeovimUnstable neovim-nightly {
    luaRcContent = ''
      -- Add Nix-bundled treesitter parsers
      vim.opt.rtp:prepend("${treesitterGrammars}")

      vim.opt.rtp:prepend("${configDir}")
      dofile("${configDir}/init.lua")
    '';
    vimAlias = true;
    viAlias = false;
    inherit wrapperArgs;
  };
in
wrapped.overrideAttrs {
  passthru = {
    # Expose for devshell to create config-less version
    inherit
      neovim-nightly
      tools
      wrapperArgs
      treesitterGrammars
      ;
  };
}
