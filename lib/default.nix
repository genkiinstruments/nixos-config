_: {
  mvim-base =
    {
      flake,
      pkgs,
      configSource ? flake + "/home/nvim",
      NVIM_APPNAME,
      ...
    }:
    with pkgs;
    let
      nvim-lsp-packages = [
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
        python3Packages.python-lsp-server
        python3Packages.python-lsp-ruff
        basedpyright
        typos-lsp
        typos
        nixfmt-rfc-style
        clang-tools
        nodejs
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
        govulncheck
        iferr
        impl
        zls

        # mvim custom
        sqlite # dadbod
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

        # fzf-lua
        viu
        chafa
        ueberzugpp

        # Snacks
        imagemagick
        tectonic
        ghostscript
        mermaid-cli

        ripgrep
        fd
        fzf
        cargo
        python3 # sqlfluff
        unzip
        lazygit
        coreutils
      ] ++ lib.optional (stdenv.hostPlatform.system != "aarch64-linux") ast-grep;

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
      neovim = wrapNeovimUnstable neovim-unwrapped (
        neovimUtils.makeNeovimConfig {
          wrapRc = false;
          withRuby = false;
          # extraLuaPackages = ps: [ (ps.callPackage ./lua-tiktoken.nix { }) ];
        }
      );

      lspEnv = pkgs.buildEnv {
        name = "lsp-servers";
        paths = nvim-lsp-packages;
      };
    in
    {
      inherit
        treesitter-grammars
        nvim-lsp-packages
        neovim
        lspEnv
        configSource
        ;

      # Common environment setup
      commonEnvVars = {
        PATH = "${pkgs.coreutils}/bin:${lspEnv}/bin:${neovim}/bin";
        NVIM_APPNAME = NVIM_APPNAME;
      };

      # Common packages needed for mvim
      commonPackages = nvim-lsp-packages ++ [
        neovim
        pkgs.git
      ];

      # Helper function to setup config directory
      setupConfigScript = configDestination: ''
        set -efu

        XDG_CONFIG_HOME=''${XDG_CONFIG_HOME:-$HOME/.config}
        XDG_DATA_HOME=''${XDG_DATA_HOME:-$HOME/.local/share}

        # Safety checks for required variables
        if [ -z "$XDG_CONFIG_HOME" ] || [ -z "$NVIM_APPNAME" ]; then
          echo "Error: XDG_CONFIG_HOME or NVIM_APPNAME is not set" >&2
          exit 1
        fi

        CONFIG_DIR="${configDestination}"
        if [ "$CONFIG_DIR" = "/" ] || [ -z "$CONFIG_DIR" ]; then
          echo "Error: Invalid config directory path" >&2
          exit 1
        fi

        mkdir -p "$CONFIG_DIR" "$XDG_DATA_HOME"
        chmod -R u+w "$CONFIG_DIR" 2>/dev/null || true
        rm -rf "$CONFIG_DIR"
        cp -arfT '${configSource}' "$CONFIG_DIR"
        chmod -R u+w "$CONFIG_DIR"
        echo "${treesitter-grammars.rev}" > "$CONFIG_DIR/treesitter-rev"

        # Setup lazy.nvim
        LAZY_NVIM_DIR="$XDG_DATA_HOME/${NVIM_APPNAME}/lazy/lazy.nvim"
        if [ ! -d "$LAZY_NVIM_DIR" ]; then
          mkdir -p "$(dirname "$LAZY_NVIM_DIR")"
          git clone --filter=blob:none --branch=stable https://github.com/folke/lazy.nvim.git "$LAZY_NVIM_DIR"
        fi

        # Update plugins if needed
        if ! grep -q "${treesitter-grammars.rev}" "$CONFIG_DIR/lazy-lock.json" 2>/dev/null; then
          nvim --headless "+Lazy! update" +qa > /dev/null 2>&1 &
        else
          nvim --headless -c 'quitall' > /dev/null 2>&1
        fi

        mkdir -p "$XDG_DATA_HOME/${NVIM_APPNAME}/lib/" "$XDG_DATA_HOME/${NVIM_APPNAME}/site/"

        PARSER_DIR="$XDG_DATA_HOME/${NVIM_APPNAME}/site/parser"
        if [ -d "$PARSER_DIR" ]; then
          mv "$PARSER_DIR" "$PARSER_DIR.old" 2>/dev/null || true
        fi

        ln -sfn "${treesitter-grammars}" "$PARSER_DIR"
      '';
    };
}
