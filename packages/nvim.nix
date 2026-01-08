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
      # Query-only languages that parsers inherit from but withAllGrammars doesn't include
      queryOnlyLangs = pkgs.vimPlugins.nvim-treesitter.passthru.queries;
    in
    pkgs.symlinkJoin {
      name = "treesitter-grammars";
      paths = [
        ts
        queryOnlyLangs.ecma
        queryOnlyLangs.jsx
        queryOnlyLangs.html_tags
      ]
      ++ ts.passthru.dependencies;
    };

  tools = with pkgs; [
    git
    ripgrep
    fd
    fzf
    nodejs
    tree-sitter
    nixfmt-rfc-style
    nil
    rust-analyzer
    gopls
    lua-language-server
    svelte-language-server
    typescript-language-server
    vscode-langservers-extracted
    emmet-language-server
    pyright
    ruff
    stylua
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
