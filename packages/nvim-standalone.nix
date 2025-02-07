{
  pkgs,
  inputs,
  nvim-appname ? "mvim",
}:
with pkgs;
let
  nvim-lsp-packages = [
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
    stdenv.cc # neede to compile and link nil and other packages
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
    ast-grep
    fd
    fzf
    cargo
    python3 # sqlfluff
    unzip
    bash-language-server
    lazygit

    #ocaml-ng.ocamlPackages_5_0.ocaml-lsp
    #ocaml-ng.ocamlPackages_5_0.ocamlformat
    # does not build yet on aarch64
  ] ++ lib.optional (stdenv.hostPlatform.system == "x86_64-linux") deno;
  # ++ lib.optional (!stdenv.hostPlatform.isDarwin) sumneko-lua-language-server;
  neovim = wrapNeovimUnstable neovim-unwrapped (
    neovimUtils.makeNeovimConfig {
      wrapRc = false;
      withRuby = false;
      # extraLuaPackages = ps: [ (ps.callPackage ./lua-tiktoken.nix { }) ];
    }
  );
  treesitter-grammars =
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
  lspEnv = buildEnv {
    name = "lsp-servers";
    paths = nvim-lsp-packages;
  };
in
writeShellApplication {
  name = "nvim";
  text = ''
    set -efux
    unset VIMINIT
    export PATH=${lspEnv}/bin:${neovim}/bin:$PATH
    export NVIM_APPNAME=${nvim-appname}

    XDG_CONFIG_HOME=''${XDG_CONFIG_HOME:-$HOME/.config}
    XDG_DATA_HOME=''${XDG_DATA_HOME:-$HOME/.local/share}

    mkdir -p "$XDG_CONFIG_HOME/$NVIM_APPNAME" "$XDG_DATA_HOME"
    chmod -R u+w "$XDG_CONFIG_HOME/$NVIM_APPNAME"
    rm -rf "{$XDG_CONFIG_HOME/$NVIM_APPNAME:?}"
    cp -arfT '${inputs.mvim}'/ "$XDG_CONFIG_HOME/$NVIM_APPNAME"
    chmod -R u+w "$XDG_CONFIG_HOME/$NVIM_APPNAME"
    echo "${treesitter-grammars.rev}" > "$XDG_CONFIG_HOME/$NVIM_APPNAME/treesitter-rev"

    # lock file is not in sync with treesitter-rev, force update of lazy-lock.json
    if ! grep -q "${treesitter-grammars.rev}" "$XDG_CONFIG_HOME/$NVIM_APPNAME/lazy-lock.json"; then
      # annoyingly we would run this on every nvim invocation again because we overwrite the lock file
      nvim --headless "+Lazy! update" +qa
    else
      nvim --headless -c 'quitall' # install plugins, if needed
    fi
    mkdir -p "$XDG_DATA_HOME/$NVIM_APPNAME/lib/" "$XDG_DATA_HOME/$NVIM_APPNAME/site/"
    # ln -sfT "${vimPlugins.telescope-fzf-native-nvim}/build/libfzf.so" "$XDG_DATA_HOME/$NVIM_APPNAME/lib/libfzf.so"
    ln -sfT "${treesitter-grammars}" "$XDG_DATA_HOME/$NVIM_APPNAME/site/parser"

    exec nvim "$@"
  '';
}
