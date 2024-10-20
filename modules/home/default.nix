{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    inputs.nix-index-database.hmModules.nix-index
    inputs.catppuccin.homeManagerModules.catppuccin
  ];

  home.enableNixpkgsReleaseCheck = false;
  home.stateVersion = "23.05";

  catppuccin.enable = true;
  catppuccin.flavor = "mocha";

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
          (
            if pkgs.stdenv.isDarwin then
              ''
                # Darwin openssh does not support FIDO2. Overwrite PATH with binaries in current system.
                fish_add_path --path --move /run/current-system/sw/bin

                #-------------------------------------------------------------------------------
                # SSH Agent
                #-------------------------------------------------------------------------------
                function __ssh_agent_is_started -d "check if ssh agent is already started"
                    if begin
                            test -f $SSH_ENV; and test -z "$SSH_AGENT_PID"
                        end
                        source $SSH_ENV >/dev/null
                    end

                    if test -z "$SSH_AGENT_PID"
                        return 1
                    end

                    ssh-add -l >/dev/null 2>&1
                    if test $status -eq 2
                        return 1
                    end
                end

                function __ssh_agent_start -d "start a new ssh agent"
                    ssh-agent -c | sed 's/^echo/#echo/' >$SSH_ENV
                    chmod 600 $SSH_ENV
                    source $SSH_ENV >/dev/null
                    ssh-add
                end

                if not test -d $HOME/.ssh
                    mkdir -p $HOME/.ssh
                    chmod 0700 $HOME/.ssh
                end

                if test -d $HOME/.gnupg
                    chmod 0700 $HOME/.gnupg
                end

                if test -z "$SSH_ENV"
                    set -xg SSH_ENV $HOME/.ssh/environment
                end

                if not __ssh_agent_is_started
                    __ssh_agent_start
                end

                #-------------------------------------------------------------------------------
                # Ghostty Shell Integration
                #-------------------------------------------------------------------------------
                # Ghostty supports auto-injection but Nix-darwin hard overwrites XDG_DATA_DIRS
                # which make it so that we can't use the auto-injection. We have to source
                # manually.
                if set -q GHOSTTY_RESOURCES_DIR
                    source "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish"
                end

                #-------------------------------------------------------------------------------
                # Programs
                #-------------------------------------------------------------------------------
                # Vim: We should move this somewhere else but it works for now
                mkdir -p $HOME/.vim/{backup,swap,undo}

                # Homebrew
                if test -d /opt/homebrew
                    set -gx HOMEBREW_PREFIX /opt/homebrew
                    set -gx HOMEBREW_CELLAR /opt/homebrew/Cellar
                    set -gx HOMEBREW_REPOSITORY /opt/homebrew
                    set -q PATH; or set PATH ""
                    set -gx PATH /opt/homebrew/bin /opt/homebrew/sbin $PATH
                    set -q MANPATH; or set MANPATH ""
                    set -gx MANPATH /opt/homebrew/share/man $MANPATH
                    set -q INFOPATH; or set INFOPATH ""
                    set -gx INFOPATH /opt/homebrew/share/info $INFOPATH
                end

                # Hammerspoon
                if test -d "/Applications/Hammerspoon.app"
                    set -q PATH; or set PATH ""
                    set -gx PATH "/Applications/Hammerspoon.app/Contents/Frameworks/hs" $PATH
                end

                # Add ~/.local/bin
                set -q PATH; or set PATH ""
                set -gx PATH "$HOME/.local/bin" $PATH
              ''
            else
              ""
          )
        ])
      );
    };

    ssh.enable = true;
    bat.enable = true;

    git = {
      enable = true;
      lfs.enable = true;
      userEmail = "olafur@genkiinstruments.com";
      userName = "multivac61";
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
        color.ui = true;
        github.user = "multivac61";
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

  # Hyper-key config
  home.file.".config/karabiner/karabiner.json".source = ./config/karabiner/karabiner.json;
  home.file.".config/ghostty/config".source = ./config/ghostty/config;
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
    # moonlight-qt

    sesh
    gh-dash
    fzf
    gum

    btop
    cachix
    xsel # for lazygit copy/paste stuff to clipboard

    # FIXME: Add as extraPackages to nvim
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
