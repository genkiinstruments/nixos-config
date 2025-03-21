{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    inputs.catppuccin.homeManagerModules.catppuccin
  ];
  home = {
    enableNixpkgsReleaseCheck = false;

    stateVersion = "23.05";

    file.".config/ghostty/config".source = ./config/ghostty/config;
    file.".hammerspoon/init.lua".source = ./config/hammerspoon/init.lua;
    file.".hushlogin".text = "";

    sessionVariables.EDITOR = "nvim";

    packages = with pkgs; [
      wget
      zip
      magic-wormhole-rs
      neofetch
      cachix
      bitwarden-cli
      (claude-code.overrideAttrs (_old: rec {
        version = "0.2.52";
        src = fetchzip {
          url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
          hash = "sha256-Yhsmc95rzMEMB2e4Chs6E8r2cFZeOPAs6pH5fH5nC5E=";
        };
        npmDepsHash = "sha256-L+aGG3qHdoO+pdgSq+BhbhDszmIWWssqbyviytokzuI=";
      }))
      (sesh.overrideAttrs (_old: {
        src = fetchFromGitHub {
          owner = "joshmedeski";
          repo = "sesh";
          rev = "476dbf94026d367d145c9f1ccc88bc8078cc8660";
          sha256 = "sha256-YFvUYacuvyzNXwY+y9kI4tPlrlojDuZpR7VaTGdVqb8=";
        };
      }))
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
    lazygit.enable = false;
  };

  programs = {
    yazi.enable = true;
    gh-dash.enable = true;
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
        # Classhing with tmux keybindngs
        keybinding.commits.moveDownCommit = "<c-J>";
        keybinding.commits.moveUpCommit = "<c-K>";
        keybinding.commits.openLogMenu = "<c-L>";
        customCommands = [
          {
            key = "C";
            command = ''git commit -m "{{ .Form.Type }}{{if .Form.Scopes}}({{ .Form.Scopes }}){{end}}: {{ .Form.Description }}" -m "{{ .Form.LongDescription }}"'';
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
        cat = "bat";
      };
      interactiveShellInit = lib.strings.concatStrings (
        lib.strings.intersperse "\n" ([
          (builtins.readFile ./config/fish/config.fish)
          "set -g SHELL ${pkgs.fish}/bin/fish"
        ])
      );
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
    fd.enable = true;
    git = {
      enable = true;
      lfs.enable = true;
      userEmail = "olafur@genkiinstruments.com";
      userName = "multivac61";
      extraConfig = {
        init.defaultBranch = "main";
        core.autocrlf = "input";
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
  };
}
