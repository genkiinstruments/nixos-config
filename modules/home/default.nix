{
  inputs,
  pkgs,
  lib,
  perSystem,
  ...
}:
{
  imports = [
    inputs.catppuccin.homeModules.catppuccin
  ];

  home = {
    enableNixpkgsReleaseCheck = false;

    stateVersion = "23.05";

    file.".config/ghostty/config".source = ./config/ghostty/config;
    file.".hammerspoon/init.lua".source = ./config/hammerspoon/init.lua;
    file.".hushlogin".text = "";
    file.".local/bin/tmux-osc52" = {
      source = ./config/scripts/tmux-osc52;
      executable = true;
    };
    file.".local/bin/tmux-toggle-app" = {
      source = ./config/scripts/tmux-toggle-app;
      executable = true;
    };

    sessionVariables = {
      NVIM_APPNAME = "mvim";
      EDITOR = "mvim";
    };

    packages =
      with pkgs;
      [
        wget
        zip
        magic-wormhole-rs
        neofetch
        mediainfo # for mpv / yazi setup
        television # tv binary for sesh
        perSystem.self.mvim
      ]
      ++ (with perSystem.nix-ai-tools; [
        gemini-cli
        claude-code
        claude-code-acp
      ]);
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
    lazygit.enable = false;
  };

  programs = {
    sesh = {
      enable = true;
      enableTmuxIntegration = false; # using custom keybind in tmux.conf
      settings.dir_length = 2;
    };
    jq.enable = true;
    yazi.enable = true;
    yazi.enableFishIntegration = true;
    mpv.enable = true;
    gh-dash = {
      enable = true;
      settings = {
        theme.colors = {
          text = {
            primary = "#cdd6f4";
            secondary = "#a6e3a1";
            inverted = "#1e1e2e";
            faint = "#bac2de";
            warning = "#f38ba8";
            success = "#a6e3a1";
          };
          background = {
            selected = "#313244";
          };
          border = {
            primary = "#a6e3a1";
            secondary = "#6c7086";
            faint = "#313244";
          };
        };
      };
    };
    btop.enable = true;
    ssh = {
      enable = true;
      package = pkgs.openssh;
      enableDefaultConfig = false;
    };

    fzf = {
      enable = true;
      enableFishIntegration = true;
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
      enableFishIntegration = true;
      icons = "auto";
      git = true;
    };
    lazygit = {
      enable = true;
      settings = {
        git.pagers = [ { pager = "${pkgs.diff-so-fancy}/bin/diff-so-fancy"; } ];
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
        # Classhing with tmux keybindngs
        keybinding.commits.moveDownCommit = "<c-J>";
        keybinding.commits.moveUpCommit = "<c-K>";
        keybinding.commits.openLogMenu = "<c-L>";
        customCommands = [
          {
            key = "C";
            command = ''git commit -m "{{ .Form.Type }}{{if .Form.Scopes}}({{ .Form.Scopes }}){{end}}: {{ .Form.Description }}"'';
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
                    name = "Chores";
                    description = "Other changes that don't modify src or test files";
                    value = "chore";
                  }
                  {
                    name = "Documentation";
                    description = "Documentation only changes";
                    value = "docs";
                  }
                  {
                    name = "Styles";
                    description = "Changes that affect white-space, formatting, missing semi-colons, etc";
                    value = "style";
                  }
                  {
                    name = "Code Refactoring";
                    description = "Neither fixes a bug nor adds a feature";
                    value = "refactor";
                  }
                  {
                    name = "Performance Improvements";
                    description = "Improves performance";
                    value = "perf";
                  }
                  {
                    name = "Tests";
                    description = "Adding missing tests or correting existing tests";
                    value = "test";
                  }
                  {
                    name = "Builds";
                    description = "Build system or external dependencies";
                    value = "build";
                  }
                  {
                    name = "Continuous Integration";
                    description = "CI configuration files and scripts";
                    value = "ci";
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
                type = "input";
                title = "Enter the short description of the change.";
                key = "Description";
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
          {
            key = "F";
            description = "auto-commit nix fmt changes";
            command = "git commit -m \"chore: nix fmt\"";
            context = "files";
            loadingText = "Committing nix fmt changes...";
          }
          {
            key = "L";
            description = "auto-commit lazy-lock.json changes";
            command = "git commit -m \"chore: update lazy-lock.json\"";
            context = "files";
            loadingText = "Committing lazy-lock.json changes...";
          }
        ];
      };
    };
    atuin = {
      enable = true;
      enableFishIntegration = false; # Manual keybindings in config.fish
      settings = {
        exit_mode = "return-query";
        keymap_mode = "auto";
        enter_accept = true;
        update_check = false;
        filter_mode = "directory";
        workspaces = true;

        stats.common_prefix = [
          "sudo"
          "time"
        ];
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
      stdlib = # bash
        ''
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
        n = "mvim";
        nssh = "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no";
      };
      interactiveShellInit = lib.strings.concatStrings (
        lib.strings.intersperse "\n" [
          (builtins.readFile ./config/fish/config.fish)
          "set -g SHELL ${pkgs.fish}/bin/fish"
        ]
      );
    };
    bat.enable = true;
    ripgrep.enable = true;
    ripgrep.arguments = [
      "--follow"
      "--pretty"
      "--hidden"
      "--smart-case"
    ];
    fd.enable = true;
    git = {
      enable = true;
      lfs.enable = true;
      settings = {
        init.defaultBranch = "main";
        core.autocrlf = "input";
        pull.rebase = true;
        rebase.autoStash = true;
        url."ssh://git@github.com/".pushInsteadOf = "https://github.com/";
        gpg.format = "ssh";
        color.ui = true;
        alias = {
          co = "checkout";
          cm = "commit";
          st = "status";
          br = "branch";
          df = "diff";
          lg = "log";
          pl = "pull";
          ps = "push";
        };
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
    tmux = {
      enable = true;
      baseIndex = 1;
      escapeTime = 0;
      historyLimit = 1000000;
      mouse = true;
      newSession = true;
      shell = "${pkgs.fish}/bin/fish";
      plugins = with pkgs.tmuxPlugins; [
        sensible
        vim-tmux-navigator
      ];
      extraConfig = lib.strings.concatStrings (
        lib.strings.intersperse "\n" [
          "set -g default-command ${pkgs.fish}/bin/fish"
          (builtins.readFile ./config/tmux/tmux.conf)
        ]
      );
    };
    starship.enable = true;
    starship.enableFishIntegration = true;
    starship.settings = {
      add_newline = false;
      scan_timeout = 200;
      command_timeout = 1000;
    };
  };
}
