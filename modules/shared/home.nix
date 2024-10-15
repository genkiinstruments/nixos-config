{
  pkgs,
  lib,
  ...
}:
{
  home.enableNixpkgsReleaseCheck = false;
  home.stateVersion = "23.05";

  xdg.enable = true; # Needed for fish interactiveShellInit hack

  programs = {
    gh = {
      enable = true;
      settings.git_protocol = "ssh";
    };
    eza = {
      enable = true;
      enableFishIntegration = true;
      icons = true;
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
      interactiveShellInit = ''
        # bind to ctrl-p in normal and insert mode, add any other bindings you want here too
        bind \cp _atuin_search
        bind -M insert \cp _atuin_search
        bind \cr _atuin_search
        bind -M insert \cr _atuin_search

        # Use Ctrl-f to complete a suggestion in vi mode
        bind -M insert \cf accept-autosuggestion

        set -gx DIRENV_LOG_FORMAT ""

        function fish_user_key_bindings
          fish_vi_key_bindings
        end

        set fish_vi_force_cursor
        set fish_cursor_default     block      blink
        set fish_cursor_insert      line       blink
        set fish_cursor_replace_one underscore blink
        set fish_cursor_visual      block

        # To back up previous home manager configurations
        set -Ux HOME_MANAGER_BACKUP_EXT ~/.nix-bak
      '';

      shellInit = ''
        set fish_greeting # Disable greeting

        # https://github.com/d12frosted/environment/blob/78486b74756142524a4ccd913c85e3889a138e10/nix/home.nix#L117 prompt configurations
        # see https://github.com/LnL7/nix-darwin/issues/122
        set -ga PATH $HOME/.local/bin
        set -ga PATH /run/wrappers/bin
        set -ga PATH $HOME/.nix-profile/bin
        set -ga PATH /run/current-system/sw/bin
        set -ga PATH /nix/var/nix/profiles/default/bin

        # Adapt construct_path from the macOS /usr/libexec/path_helper executable for
        # fish usage;
        #
        # The main difference is that it allows to control how extra entries are
        # preserved: either at the beginning of the VAR list or at the end via first
        # argument MODE.
        #
        # Usage:
        #
        #   __fish_macos_set_env MODE VAR VAR-FILE VAR-DIR
        #
        #   MODE: either append or prepend
        #
        # Example:
        #
        #   __fish_macos_set_env prepend PATH /etc/paths '/etc/paths.d'
        #
        #   __fish_macos_set_env append MANPATH /etc/manpaths '/etc/manpaths.d'
        #
        # [1]: https://opensource.apple.com/source/shell_cmds/shell_cmds-203/path_helper/path_helper.c.auto.html .
        #
        function macos_set_env -d "set an environment variable like path_helper does (macOS only)"
          # noops on other operating systems
          if test $KERNEL_NAME darwin
            set -l result
            set -l entries

            # echo "1. $argv[2] = $$argv[2]"

            # Populate path according to config files
            for path_file in $argv[3] $argv[4]/*
              if [ -f $path_file ]
                while read -l entry
                  if not contains -- $entry $result
                    test -n "$entry"
                    and set -a result $entry
                  end
                end <$path_file
              end
            end

            # echo "2. $argv[2] = $result"

            # Merge in any existing path elements
            set entries $$argv[2]
            if test $argv[1] = "prepend"
              set entries[-1..1] $entries
            end
            for existing_entry in $entries
              if not contains -- $existing_entry $result
                if test $argv[1] = "prepend"
                  set -p result $existing_entry
                else
                  set -a result $existing_entry
                end
              end
            end

            # echo "3. $argv[2] = $result"

            set -xg $argv[2] $result
          end
        end
        macos_set_env prepend PATH /etc/paths '/etc/paths.d'

        set -ga MANPATH $HOME/.local/share/man
        set -ga MANPATH $HOME/.nix-profile/share/man
        if test $KERNEL_NAME darwin
          set -ga MANPATH /opt/homebrew/share/man
        end
        set -ga MANPATH /run/current-system/sw/share/man
        set -ga MANPATH /nix/var/nix/profiles/default/share/man
        macos_set_env append MANPATH /etc/manpaths '/etc/manpaths.d'

        if test $KERNEL_NAME darwin
          set -gx HOMEBREW_PREFIX /opt/homebrew
          set -gx HOMEBREW_CELLAR /opt/homebrew/Cellar
          set -gx HOMEBREW_REPOSITORY /opt/homebrew
          set -gp INFOPATH /opt/homebrew/share/info
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
      '';
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
      sensibleOnTop = true;
      terminal = "tmux-256color";
      plugins = with pkgs.tmuxPlugins; [
        sensible
        vim-tmux-navigator
        yank
        fzf-tmux-url
        tmux-thumbs
        {
          plugin = extrakto;
          extraConfig = ''
            set -g @extrakto_grab_area "window recent"
          '';
        }
      ];
      extraConfig = (builtins.readFile ./config/tmux.conf);
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

  xdg.configFile."ghostty/config".source = ../shared/config/ghostty/config;
  home.file.".hushlogin".text = "";
  home.packages = with pkgs; [
    wget
    zip
    moonlight-qt
    magic-wormhole-rs
    neofetch
    nb
    # TODO: Add once merged in nixpkgs
    age-plugin-fido2-hmac
    # bitwarden-cli

    # TODO: update sesh in nixpkgs. currently using the one in ~/.local/bin/
    # sesh
    gh-dash
    fzf
    gum

    btop
    cachix
    xsel # for lazygit copy/paste stuff to clipboard

    # neovim
    neovim
    ripgrep
    fd
    ripgrep
    fd
    nodejs
    cargo
    go
    # workaround for nvim-spectre...
    (writeShellScriptBin "gsed" ''exec ${pkgs.gnused}/bin/sed "$@"'')
  ];
}
