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
  home = {
    enableNixpkgsReleaseCheck = false;
    stateVersion = "23.05";
    sessionVariables.EDITOR = "n";
    file.".config/karabiner/karabiner.json".source = ./config/karabiner/karabiner.json;
    # TODO: Add to home-manager once in srvos.nixpkgs
    file.".config/ghostty/config".source = ./config/ghostty/config;
    file.".hushlogin".text = "";

    packages = with pkgs; [
      wget
      zip
      magic-wormhole-rs
      neofetch
      nb
      age-plugin-fido2-hmac
      gh-dash

      # sesh and dependencies
      sesh
      gum

      cachix

      moonlight-qt

      # FIXME: Currently broken in nixpkgs: https://github.com/NixOS/nixpkgs/issues/339576
      # bitwarden-cli
    ];
  };

  catppuccin = {
    enable = true;
    flavor = "mocha";
    # See issues with IFD: https://github.com/catppuccin/nix?tab=readme-ov-file#-faq
    fzf.enable = false;
    starship.enable = false;
    cava.enable = false;
    gh-dash.enable = false;
    imv.enable = false;
    swaylock.enable = false;
    mako.enable = false;
  };

  programs = {
    btop.enable = true;
    ssh.enable = true;
    ssh.package = pkgs.openssh;
    ssh.extraConfig = "SetEnv TERM=xterm-256color";
    fzf = {
      enable = true;
      defaultCommand = "rg --files --no-ignore --hidden --follow --glob '!.git/*'";
      fileWidgetOptions = [
        "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
      ];
    };
    gh = {
      enable = true;
      settings.git_protocol = "ssh";
    };
    eza = {
      enable = true;
      icons = "auto";
      git = true;
    };
    nix-index.enable = true;
    nix-index-database.comma.enable = true;
    lazygit = {
      enable = true;
      settings = {
        git.paging.pager = "${pkgs.diff-so-fancy}/bin/diff-so-fancy";
        git.truncateCopiedCommitHashesTo = 40;
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
        keybinding.files.commitChangesWithEditor = "<disabled>";
        customCommands = [
          {
            key = "C";
            command = ''git commit -m "{{ .Form.Type }}{{if .Form.Scopes}}({{ .Form.Scopes }}){{end}}{{ .Form.Breaking }}: {{ .Form.Description }}" -m "{{ .Form.LongDescription }}"'';
            description = "commit with commitizen and long description";
            context = "global";
            prompts = [
              {
                type = "menu";
                title = "Select the type of change you are committing.";
                key = "Type";
                options = [
                  {
                    name = "Feature";
                    description = "a new feature";
                    value = "feat";
                  }
                  {
                    name = "Fix";
                    description = "a bug fix";
                    value = "fix";
                  }
                  {
                    name = "Documentation";
                    description = "Documentation only changes";
                    value = "docs";
                  }
                  {
                    name = "Styles";
                    description = "Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)";
                    value = "style";
                  }
                  {
                    name = "Code Refactoring";
                    description = "A code change that neither fixes a bug nor adds a feature";
                    value = "refactor";
                  }
                  {
                    name = "Performance Improvements";
                    description = "A code change that improves performance";
                    value = "perf";
                  }
                  {
                    name = "Tests";
                    description = "Adding missing tests or correcting existing tests";
                    value = "test";
                  }
                  {
                    name = "Builds";
                    description = "Changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm)";
                    value = "build";
                  }
                  {
                    name = "Continuous Integration";
                    description = "Changes to our CI configuration files and scripts (example scopes: Travis, Circle, BrowserStack, SauceLabs)";
                    value = "ci";
                  }
                  {
                    name = "Chores";
                    description = "Other changes that don't modify src or test files";
                    value = "chore";
                  }
                  {
                    name = "Reverts";
                    description = "Reverts a previous commit";
                    value = "revert";
                  }
                ];
              }
              {
                type = "input";
                title = "Enter the scope(s) of this change.";
                key = "Scopes";
              }
              {
                type = "menu";
                title = "Breaking change?";
                key = "Breaking";
                options = [
                  {
                    name = "Default";
                    description = "Not a breaking change";
                    value = "";
                  }
                  {
                    name = "BREAKING CHANGE";
                    description = "Introduced a breaking change";
                    value = "!";
                  }
                ];
              }
              {
                type = "input";
                title = "Enter the short description of the change.";
                key = "Description";
              }
              {
                type = "input";
                title = "Enter a longer description of the change (optional).";
                key = "LongDescription";
              }
            ];
          }
          {
            key = "O";
            description = "open repo in GitHub";
            command = "gh repo view --web";
            context = "global";
            loadingText = "Opening GitHub repo in browser...";
          }
        ];
      };
    };
    atuin = {
      enable = true;
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
    };
    direnv = {
      enable = true;
      silent = true;
      nix-direnv.enable = true; # Adds FishIntegration automatically
      config.warn_timeout = "30m";
      stdlib = ''
        # Avoid cluttering project directories which often conflicts with tooling, e.g., `mix`
        # https://github.com/direnv/direnv/wiki/Customizing-cache-location
        # Centralize direnv layouts in $HOME/.cache/direnv/layouts
        : ''${XDG_CACHE_HOME:=$HOME/.cache}
        declare -A direnv_layout_dirs
        direnv_layout_dir() {
          echo "''${direnv_layout_dirs[$PWD]:=$(
            echo -n "$XDG_CACHE_HOME"/direnv/layouts/
            echo -n "$PWD" | shasum | cut -d ' ' -f 1
          )}"
        }
      '';
    };
    fish = {
      enable = true;
      shellAliases = {
        n = "NVIM_APPNAME=mvim nvim";
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
        cat = "bat";
      };
      interactiveShellInit =
        if pkgs.stdenv.isDarwin then
          ''
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

                ${pkgs.openssh}/bin/ssh-add -l >/dev/null 2>&1
                if test $status -eq 2
                    return 1
                end
            end

            function __ssh_agent_start -d "start a new ssh agent"
                ${pkgs.openssh}/bin/ssh-agent -c | sed 's/^echo/#echo/' >$SSH_ENV
                chmod 600 $SSH_ENV
                source $SSH_ENV >/dev/null
                ${pkgs.openssh}/bin/ssh-add
            end

            if not test -d $HOME/.ssh
                mkdir -p $HOME/.ssh
                chmod 0700 $HOME/.ssh
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
            # which make it so that we can't use the auto-injection. We have to source manually.
            if set -q GHOSTTY_RESOURCES_DIR
                source "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish"
            end

            #-------------------------------------------------------------------------------
            # Programs
            #-------------------------------------------------------------------------------
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

            # Do not show any greeting
            set fish_greeting

            #-------------------------------------------------------------------------------
            # Atuin keybindings
            #-------------------------------------------------------------------------------
            # bind to ctrl-p in normal and insert mode
            bind \cp _atuin_search
            bind -M insert \cp _atuin_search
            bind \cr _atuin_search
            bind -M insert \cr _atuin_search

            bind \cL clear

            #-------------------------------------------------------------------------------
            # VI keybindings
            #-------------------------------------------------------------------------------
            # Use Ctrl-f to complete a suggestion in vi mode
            bind -M insert \cf accept-autosuggestion

            fish_vi_key_bindings
            set fish_vi_force_cursor
            set fish_cursor_default block blink
            set fish_cursor_insert line blink
            set fish_cursor_replace_one underscore blink
            set fish_cursor_visual block
          ''
        else
          "";
    };
    bash.enable = true;
    bat.enable = true;
    ripgrep.enable = true;
    ripgrep.arguments = [
      "--follow"
      "--pretty"
      "--hidden"
      "--smart-case"
    ];
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
        ".direnv"
        ".devenv"

        # nix
        "result"
        "result-*"

        # vim
        ".*.swp"

        ".DS_Store"

        # Work notes
        "WORK.md"
      ];
    };

    yazi.enable = true;

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
            name = "elixir";
            auto-format = true;
            language-id = "elixir";
            language-servers = [
              "elixir-ls"
              "tailwindcss-ls"
              "vscode-html-language-server"
            ];
          }
          {
            name = "heex";
            auto-format = true;
            language-id = "phoenix-heex";
            language-servers = [
              "elixir-ls"
              "tailwindcss-ls"
              "vscode-html-language-server"
            ];
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
      shell = "${pkgs.fish}/bin/fish";
      plugins = with pkgs.tmuxPlugins; [
        sensible
        vim-tmux-navigator
        yank
        fzf-tmux-url
        {
          plugin = tmux-thumbs;
          extraConfig = if pkgs.stdenv.isDarwin then "set -g @thumbs-command 'echo -n {} | pbcopy'" else "";
        }
        {
          plugin = extrakto;
          extraConfig = "set -g @extrakto_grab_area 'window recent'";
        }
      ];
      extraConfig = lib.strings.concatStrings (
        lib.strings.intersperse "\n" ([
          "set -g default-command ${pkgs.fish}/bin/fish"
          (builtins.readFile ./config/tmux/tmux.conf)
        ])
      );
    };

    starship.enable = true;
    starship.settings.add_newline = false;

    neovim = {
      enable = true;
      extraPackages = with pkgs; [
        xsel # for lazygit copy/paste to clipboard
        ripgrep
        ast-grep
        fd
        nodejs
        cargo
        go
        nixfmt-rfc-style
      ];
    };
  };
}
