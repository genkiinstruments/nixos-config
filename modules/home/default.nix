{
  pkgs,
  lib,
  ...
}:
{
  home.enableNixpkgsReleaseCheck = false;
  home.stateVersion = "23.05";

  programs = {
    gh = {
      enable = true;
      settings.git_protocol = "ssh";
    };
    eza = {
      enable = true;
      enableFishIntegration = true;
      icons = "auto";
      git = true;
    };
    nix-index = {
      enable = true;
      enableFishIntegration = true;
    };
    nix-index-database.comma.enable = true;

    lazygit = {
      enable = true;
      settings = {
        git = {
          paging = {
            pager = "${pkgs.diff-so-fancy}/bin/diff-so-fancy";
          };
        };
        gui = {
          language = "en";
          mouseEvents = false;
          sidePanelWidth = 0.3;
          mainPanelSplitMode = "flexible";
          showFileTree = true;
          nerdFontsVersion = 3;
          commitHashLength = 6;
          showDivergenceFromBaseBranch = "arrowAndNumber";
          skipDiscardChangeWarning = true;
        };
        quitOnTopLevelReturn = true;
        disableStartupPopups = true;
        promptToReturnFromSubprocess = false;
      };
    };
    atuin = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        exit_mode = "return-query";
        keymap_mode = "auto";
        enter_accept = true;
        update_check = false;
        sync_frequency = "0";
      };
    };
    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
    direnv = {
      enable = true;
      silent = true;
      nix-direnv.enable = true; # Adds FishIntegration automatically
      config.warn_timeout = "30m";
    };
    fish = {
      enable = true;
      shellAliases = {
        n = "nvim";
        da = "direnv allow";
        dr = "direnv reload";
        ga = "git add";
        gc = "git commit";
        gco = "git checkout";
        gcp = "git cherry-pick";
        gdiff = "git diff";
        gl = "git pull";
        gp = "git push";
        gs = "git status";
        gt = "git tag";
        c = "clear";
        lg = "lazygit";
      };
      interactiveShellInit = lib.strings.concatStrings (
        lib.strings.intersperse "\n" ([
          (builtins.readFile ./config/fish/config.fish)
          "set -g SHELL ${pkgs.fish}/bin/fish"
          (if pkgs.stdenv.isDarwin then "fish_add_path --path --move /run/current-system/sw/bin" else "")
        ])
      );
    };

    ssh.enable = true;

    bat.enable = true;

    git = {
      enable = true;
      lfs.enable = true;
      extraConfig = {
        init.defaultBranch = "main";
        core = {
          editor = "nvim";
          autocrlf = "input";
        };
        pull.rebase = true;
        rebase.autoStash = true;
        url."ssh://git@github.com/".pushInsteadOf = "https://github.com/";
        gpg.format = "ssh";
        user.signingKey = "~/.ssh/id_ed25519_sk";
      };
      ignores = [
        # direnv
        ".direnv"
        ".envrc"

        # nix
        "result"
        "result-*"

        # vim
        ".*.swp"

        # VSCode
        ".vscode"

        # Work notes
        "WORK.md"
      ];
    };

    yazi = {
      enable = true;
      enableFishIntegration = true;
    };

    helix = {
      enable = true;
      extraPackages = with pkgs; [
        marksman
        markdown-oxide
        nixpkgs-fmt
        nil
        codeium
      ];
      settings = {
        editor = {
          line-number = "relative";
          cursorline = true;
          color-modes = true;
          lsp.display-messages = true;
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };
          indent-guides.render = true;
        };
        keys.normal = {
          space = {
            space = "file_picker";
            w = ":w";
            q = ":q";
          };
          esc = [
            "collapse_selection"
            "keep_primary_selection"
          ];
        };
      };
      languages = {
        language-server.clangd = {
          command = "clangd";
          args = [
            "--compile-commands-dir=build"
            "--background-index"
            "--clang-tidy"
            "--all-scopes-completion"
            "--function-arg-placeholders"
          ];
        };
        language = [
          {
            name = "cpp";
            auto-format = true;
            language-servers = [ "clangd" ];
          }
          {
            name = "nix";
            auto-format = true;
            scope = "source.nix";
            injection-regex = "nix";
            file-types = [ "nix" ];
            shebangs = [ ];
            comment-token = "#";
            formatter = {
              command = "nixpkgs-fmt";
            };
            language-servers = [
              "nil"
              "codeium"
            ];
            indent = {
              tab-width = 2;
              unit = "  ";
            };
          }
        ];
      };
    };

    tmux = {
      enable = true;
      baseIndex = 1;
      escapeTime = 0;
      historyLimit = 1000000;
      mouse = true;
      newSession = true;
      prefix = "C-Space";
      plugins = with pkgs.tmuxPlugins; [
        sensible
        vim-tmux-navigator
        yank
        fzf-tmux-url
        {
          plugin = tmux-thumbs;
          extraConfig =
            if pkgs.stdenv.isDarwin then
              ''
                set -g @thumbs-command 'echo -n {} | pbcopy'
              ''
            else
              "";
        }
        {
          plugin = extrakto;
          extraConfig = ''
            set -g @extrakto_grab_area "window recent"
          '';
        }
      ];
      extraConfig = lib.strings.concatStrings (
        lib.strings.intersperse "\n" ([
          (builtins.readFile ./config/tmux/tmux.conf)
          "set -g default-command ${pkgs.fish}/bin/fish"
        ])
      );
    };

    starship = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        add_newline = false;
        command_timeout = 1000;
        scan_timeout = 3;
      };
    };
  };

  xdg.configFile."ghostty/config".source = ./config/ghostty/config;
  home.file.".hushlogin".text = "";
  home.packages = with pkgs; [
    wget
    zip
    magic-wormhole-rs
    neofetch
    nb
    age-plugin-fido2-hmac

    # FIXME: Currently broken in nixpkgs: https://github.com/NixOS/nixpkgs/issues/339576
    # bitwarden-cli
    # FIXME: Also broken.
    # moonlight-qt

    sesh
    gh-dash
    fzf
    gum

    btop
    cachix
    xsel # for lazygit copy/paste stuff to clipboard

    neovim
    ripgrep
    fd
    nodejs
    cargo
    go
    nixfmt-rfc-style
    # workaround for nvim-spectre...
    (writeShellScriptBin "gsed" ''exec ${pkgs.gnused}/bin/sed "$@"'')
  ];
}
