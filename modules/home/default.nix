{
  pkgs,
  perSystem,
  lib,
  inputs,
  ...
}:
{
  # Disable stylix's fish theming - we use catppuccin/fish colors directly
  stylix.targets.fish.enable = false;

  # Disable stylix's yazi theming - broken after yazi v25.12.29
  # See: https://github.com/nix-community/stylix/issues/2121
  stylix.targets.yazi.enable = false;

  home = {
    enableNixpkgsReleaseCheck = false;

    stateVersion = "23.05";

    # Ensure SSH control socket directory exists
    activation.createSshSocketsDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir -p $HOME/.ssh/sockets
      run chmod 700 $HOME/.ssh/sockets
    '';

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
    file.".local/bin/git-worktree-list" = {
      source = ./config/scripts/git-worktree-list;
      executable = true;
    };
    file.".local/bin/git-worktree-add" = {
      source = ./config/scripts/git-worktree-add;
      executable = true;
    };

    # Catppuccin Mocha fish theme - https://github.com/catppuccin/fish
    file.".config/fish/themes/catppuccin-mocha.theme".text = ''
      fish_color_normal cdd6f4
      fish_color_command 89b4fa
      fish_color_param f2cdcd
      fish_color_keyword cba6f7
      fish_color_quote a6e3a1
      fish_color_redirection f5c2e7
      fish_color_end fab387
      fish_color_comment 7f849c
      fish_color_error f38ba8
      fish_color_gray 6c7086
      fish_color_selection --background=313244
      fish_color_search_match --background=313244
      fish_color_option a6e3a1
      fish_color_operator f5c2e7
      fish_color_escape eba0ac
      fish_color_autosuggestion 6c7086
      fish_color_cancel f38ba8
      fish_color_cwd f9e2af
      fish_color_user 94e2d5
      fish_color_host 89b4fa
      fish_color_host_remote a6e3a1
      fish_color_status f38ba8
      fish_pager_color_progress 6c7086
      fish_pager_color_prefix f5c2e7
      fish_pager_color_completion cdd6f4
      fish_pager_color_description 6c7086
    '';

    sessionVariables = {
      NVIM_APPNAME = "nvim";
      EDITOR = "nvim";
    };

    packages = with pkgs; [
      magic-wormhole-rs
      perSystem.llm-agents.claude-code
      perSystem.llm-agents.claude-code-acp
    ];

    shell.enableFishIntegration = true;
  };

  programs = {
    sesh = {
      enable = true;
      enableTmuxIntegration = false; # using custom keybind in tmux.conf
      settings.dir_length = 3;
    };
    jq.enable = true;
    yazi = {
      enable = true;
      enableFishIntegration = true;
      flavors = {
        catppuccin-mocha = "${inputs.yazi-flavors}/catppuccin-mocha.yazi";
      };
      theme = {
        flavor = {
          dark = "catppuccin-mocha";
          light = "catppuccin-mocha";
        };
      };
    };
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
      matchBlocks."*" = {
        controlMaster = "auto";
        controlPersist = "30m";
        controlPath = "~/.ssh/sockets/%r@%h:%p";
      };
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
        keybinding.files.commitChangesWithoutHook = "<disabled>";
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
            key = "o";
            description = "open PR in browser (or create if none exists)";
            command = "gh pr view --web || gh pr create --web";
            context = "localBranches";
            loadingText = "Opening PR in browser...";
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
            description = "auto-commit nvim-pack-lock changes";
            command = "git commit -m \"chore: update nvim plugins \"";
            context = "files";
            loadingText = "Committing nvim-pack-lock changes...";
          }
          # Worktree commands (w opens worktrees panel by default)
          {
            key = "o";
            description = "open worktree in sesh";
            command = "sesh connect '{{.SelectedWorktree.Path}}'";
            context = "worktrees";
          }
          {
            key = "O";
            description = "open worktree in sesh (alternate)";
            command = "sesh connect '{{.SelectedWorktree.Path}}'";
            context = "worktrees";
          }
          {
            key = "n";
            description = "new worktree at repo root";
            context = "worktrees";
            prompts = [
              {
                type = "input";
                title = "Worktree name";
                key = "Name";
              }
              {
                type = "menuFromCommand";
                title = "Base branch";
                key = "Base";
                command = "git branch -r --format='%(refname:short)'";
                filter = "(?P<branch>.*)";
                valueFormat = "{{ .branch }}";
                labelFormat = "{{ .branch }}";
              }
            ];
            command = "git-worktree-add '{{.Form.Name}}' '{{.Form.Base}}'";
          }
        ];
      };
    };
    atuin = {
      enable = true;
      enableFishIntegration = true; # Manual keybindings in config.fish
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
      shellInit = ''
        # Apply catppuccin-mocha theme to fish's universal variables
        yes | fish_config theme save "catppuccin-mocha" >/dev/null 2>&1
      '';
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
        c = "claude --dangerously-skip-permissions";
        cl = "clear";
        lg = "lazygit";
        cat = "bat";
        n = "nvim";
        nssh = "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no";
        # Git worktree aliases
        gwl = "git-worktree-list"; # list worktrees sorted by recent commit
        gwa = "git worktree add";
        gwr = "git worktree remove";
        gwp = "git worktree prune";
        # Sesh aliases (override sesh module default)
        s = lib.mkForce "sesh connect";
        "s." = "sesh connect .";
      };
      interactiveShellInit = builtins.readFile ./config/fish/config.fish;
    };
    bat.enable = true;
    ripgrep = {
      enable = true;
      arguments = [
        "--follow"
        "--pretty"
        "--hidden"
        "--smart-case"
      ];
    };
    fd.enable = true;
    git = {
      enable = true;
      lfs.enable = true;
      settings = {
        init.defaultBranch = "main";
        core.autocrlf = "input";
        push.default = "current";
        push.autoSetupRemote = true;
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
          # Worktree aliases
          wt = "worktree";
          wta = "worktree add";
          wtl = "worktree list";
          wtr = "worktree remove";
          wtp = "worktree prune";
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
    starship = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        add_newline = false;
        scan_timeout = 200;
        command_timeout = 1000;
      };
    };
  };
}
