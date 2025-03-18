_: {
  nvim-lsp-packages =
    { pkgs, ... }:
    with pkgs;
    [
      nodejs # copilot
      terraform-ls
      pyright

      # based on ./suggested-pkgs.json
      gopls
      golangci-lint
      nodePackages.bash-language-server
      taplo-lsp
      marksman
      selene
      rust-analyzer
      yaml-language-server
      nil
      nixd
      shellcheck
      shfmt
      ruff
      typos-lsp
      typos
      nixfmt-rfc-style
      terraform-ls
      clang-tools
      nodePackages.prettier
      stylua

      # based on https://github.com/ray-x/go.nvim#go-binaries-install-and-update
      go
      delve
      ginkgo
      gofumpt
      golines
      gomodifytags
      gotests
      gotestsum
      gotools
      govulncheck
      iferr
      impl
      zls

      # mvim custom
      sqlite # dadbod
      gopls
      stdenv.cc # needed to compile and link nl and other packages
      elixir-ls
      emmet-language-server
      vscode-langservers-extracted # json-lsp
      lua-language-server
      sqlfluff
      svelte-language-server
      tailwindcss-language-server
      taplo
      vtsls
      xsel # for lazygit copy/paste to clipboard
      ripgrep
      fd
      fzf
      cargo
      python3 # sqlfluff
      unzip
      bash-language-server
      lazygit
      coreutils
    ]
    ++ lib.optional (stdenv.hostPlatform.system != "aarch64-linux") ast-grep;

  treesitter-grammars =
    { pkgs, ... }:
    with pkgs;
    let
      grammars = lib.filterAttrs (
        n: _: lib.hasPrefix "tree-sitter-" n
      ) vimPlugins.nvim-treesitter.builtGrammars;
      symlinks = lib.mapAttrsToList (
        name: grammar: "ln -s ${grammar}/parser $out/${lib.removePrefix "tree-sitter-" name}.so"
      ) grammars;
    in
    (runCommand "treesitter-grammars" { } ''
      mkdir -p $out
      ${lib.concatStringsSep "\n" symlinks}
    '').overrideAttrs
      (_: {
        passthru.rev = vimPlugins.nvim-treesitter.src.rev;
      });
  neovim =
    { pkgs, ... }:
    with pkgs;
    wrapNeovimUnstable neovim-unwrapped (
      neovimUtils.makeNeovimConfig {
        wrapRc = false;
        withRuby = false;
        # extraLuaPackages = ps: [ (ps.callPackage ./lua-tiktoken.nix { }) ];
      }
    );
}
