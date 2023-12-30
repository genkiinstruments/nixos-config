{ config, pkgs, lib, ... }:

let
  name = "Ólafur Bjarki Bogason";
  user = "olafur";
  email = "olafur@genkiinstruments.com";
in
{
  helix = {
    enable = true;
    settings = {
      theme = "tokyonight";

      editor = {
        line-number = "relative";
        mouse = true;
        bufferline = "multiple";
        true-color = true;
        color-modes = true;
        auto-format = true;
        auto-save = true;
        # whitespace.render = {
        #   space = "all";
        #   tab = "all";
        # };

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        file-picker = {
          hidden = false;
        };

        lsp = {
          auto-signature-help = false;
          display-messages = true;
          display-inlay-hints = true;
          # copilot-auto = true;
        };

        statusline = {
          left = [ "mode" "spinner" "version-control" "file-name" ];
          right = [ "file-type" "file-encoding" ];
          mode.normal = "NORMAL";
          mode.insert = "INSERT";
          mode.select = "SELECT";
        };

        soft-wrap = {
          enable = true;
        };
      };

      keys = {
        insert = {
          # right = "apply_copilot_completion";
        };
        normal = {
          space = {
            e = ":write";
            q = ":quit";
            space = "goto_last_accessed_file";
          };
        };
      };
    };
    languages = {
      language-server = {
        # copilot = {
        #   command = "${copilot}/bin/copilot";
        #   args = [ "--stdio" ];
        # };
        nu-lsp = {
          command = "${pkgs.nushell}/bin/nu";
          args = [ "--lsp" ];
        };
        rust-analyzer = {
          config.check.command = "clippy";
        };
        yaml-language-server = {
          config.yaml.format.enable = true;
          config.yaml.validation = true;
          config.yaml.schemas = {
            "https://json.schemastore.org/github-workflow.json" = ".github/{actions,workflows}/*.{yml,yaml}";
            "https://raw.githubusercontent.com/ansible-community/schemas/main/f/ansible-tasks.json" = "roles/{tasks,handlers}/*.{yml,yaml}";
            kubernetes = "kubernetes/*.{yml,yaml}";
          };
        };
      };
      language = [
        {
          name = "nix";
          formatter = { command = "alejandra"; };
          language-servers = [ "nil" ];
          auto-format = true;
        }
        {
          name = "rust";
          language-servers = [ "rust-analyzer" ];
        }
        {
          name = "lua";
          language-servers = [ "lua-language-server" ];
        }
        {
          name = "javascript";
          language-servers = [ "typescript-language-server" ];
        }
        {
          name = "typescript";
          language-servers = [ "typescript-language-server" ];
        }
        {
          name = "bash";
          language-servers = [ "bash-language-server" ];
        }
        {
          name = "hcl";
          language-servers = [ "terraform-ls" ];
        }
        {
          name = "tfvars";
          language-servers = [ "terraform-ls" ];
        }
        {
          name = "go";
          language-servers = [ "gopls" ];
        }
        {
          name = "nu";
          language-servers = [ "nu-lsp" ];
        }
        {
          name = "css";
          language-servers = [ "vscode-css-language-server" ];
        }
        {
          name = "html";
          language-servers = [ "vscode-html-language-server" ];
        }
        {
          name = "nickel";
          language-servers = [ ];
        }
        {
          name = "yaml";
          language-servers = [ "yaml-language-server" ];
        }
        {
          name = "toml";
          language-servers = [ "taplo" ];
        }
        {
          name = "just";
          language-servers = [ ];
        }
      ];
    };
  };
  # Shared shell configuration
  fish = {
    enable = true;
    plugins = [
      {
        name = "base16-fish";
        src = pkgs.fetchFromGitHub {
          owner = "tomyun";
          repo = "base16-fish";
          rev = "2f6dd973a9075dabccd26f1cded09508180bf5fe";
          sha256 = "PebymhVYbL8trDVVXxCvZgc0S5VxI7I1Hv4RMSquTpA=";
        };
      }
      {
        name = "hydro";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "hydro";
          rev = "a5877e9ef76b3e915c06143630bffc5ddeaba2a1";
          sha256 = "nJ8nQqaTWlISWXx5a0WeUA4+GL7Fe25658UIqKa389E=";
        };
      }
      {
        name = "done";
        src = pkgs.fetchFromGitHub {
          owner = "franciscolourenco";
          repo = "done";
          rev = "37117c3d8ed6b820f6dc647418a274ebd1281832";
          sha256 = "cScH1NzsuQnDZq0XGiay6o073WSRIAsshkySRa/gJc0=";
        };
      }
    ];
    interactiveShellInit = ''
      set -gx ATUIN_NOBIND "true"
      atuin init fish | source

      # bind to ctrl-p in normal and insert mode, add any other bindings you want here too
      bind \cp _atuin_search
      bind -M insert \cp _atuin_search

      starship init fish | source
      zoxide init fish | source
      direnv hook fish | source

      # eval (zellij setup --generate-auto-start fish | string collect)

      function fish_user_key_bindings
        fish_vi_key_bindings
      end

      set fish_vi_force_cursor
      set fish_cursor_default     block      blink
      set fish_cursor_insert      line       blink
      set fish_cursor_replace_one underscore blink
      set fish_cursor_visual      block
    '';
    shellInit = '' 
    set fish_greeting # Disable greeting

    # https://github.com/folke/tokyonight.nvim/blob/main/extras/fish/tokyonight_moon.fish
    # TokyoNight Color Palette
    set -l foreground c8d3f5
    set -l selection 2d3f76
    set -l comment 636da6
    set -l red ff757f
    set -l orange ff966c
    set -l yellow ffc777
    set -l green c3e88d
    set -l purple fca7ea
    set -l cyan 86e1fc
    set -l pink c099ff

    # Syntax Highlighting Colors
    set -g fish_color_normal $foreground
    set -g fish_color_command $cyan
    set -g fish_color_keyword $pink
    set -g fish_color_quote $yellow
    set -g fish_color_redirection $foreground
    set -g fish_color_end $orange
    set -g fish_color_error $red
    set -g fish_color_param $purple
    set -g fish_color_comment $comment
    set -g fish_color_selection --background=$selection
    set -g fish_color_search_match --background=$selection
    set -g fish_color_operator $green
    set -g fish_color_escape $pink
    set -g fish_color_autosuggestion $comment

    # Completion Pager Colors
    set -g fish_pager_color_progress $comment
    set -g fish_pager_color_prefix $cyan
    set -g fish_pager_color_completion $foreground
    set -g fish_pager_color_description $comment
    set -g fish_pager_color_selected_background --background=$selection
    
    # https://github.com/d12frosted/environment/blob/78486b74756142524a4ccd913c85e3889a138e10/nix/home.nix#L117
    # prompt configurations
    set -g hydro_symbol_prompt "λ"
    if test "$TERM" = linux
      set -g hydro_symbol_prompt ">"
    end

    # done configurations
    set -g __done_notification_command 'notify send -t "$title" -m "$message"'
    set -g __done_enabled 1
    set -g __done_allow_nongraphical 1
    set -g __done_min_cmd_duration 8000

    # see https://github.com/LnL7/nix-darwin/issues/122
    set -ga PATH ${config.xdg.configHome}/bin
    set -ga PATH $HOME/.local/bin
    set -ga PATH /run/wrappers/bin
    set -ga PATH $HOME/.nix-profile/bin
    if test $KERNEL_NAME darwin
      set -ga PATH /opt/homebrew/opt/llvm/bin
      set -ga PATH /opt/homebrew/bin
      set -ga PATH /opt/homebrew/sbin
    end
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

    set -gp NIX_PATH nixpkgs=$HOME/.nix-defexpr/channels_root/nixpkgs

    if test $KERNEL_NAME darwin
      set -gx HOMEBREW_PREFIX /opt/homebrew
      set -gx HOMEBREW_CELLAR /opt/homebrew/Cellar
      set -gx HOMEBREW_REPOSITORY /opt/homebrew
      set -gp INFOPATH /opt/homebrew/share/info
      set -gx LDFLAGS "-L/opt/homebrew/opt/llvm/lib"
      set -gx CPPFLAGS "-I/opt/homebrew/opt/llvm/include"
    end
  '';
  };

  git = {
    enable = true;
    ignores = [ "*.swp" ];
    userName = name;
    userEmail = email;
    lfs = {
      enable = true;
    };
    extraConfig = {
      init.defaultBranch = "main";
      core = {
        editor = "nvim";
        autocrlf = "input";
      };
      pull.rebase = true;
      rebase.autoStash = true;
    };
  };

  yazi = {
    enable = true;
    enableFishIntegration = true;
  };

  neovim = {
    enable = true;
    extraPackages = with pkgs; [
      # LazyVim
      lua-language-server
      stylua

      # Telescope
      ripgrep

      # neovim/nvim-lspconfig
      # Nix
      nil
      nixpkgs-fmt

      # C
      clang-tools
      neocmakelsp
      vscode-extensions.ms-vscode.cmake-tools

      # Rust
      rust-analyzer
      rustfmt
      cargo
      graphviz

      # Svelte
      nodePackages.svelte-language-server
      nodePackages.typescript-language-server
      nodePackages.prettier
      nodePackages.eslint

      nodePackages.pyright
      nodePackages.vscode-json-languageserver-bin
      ruff
      tailwindcss-language-server
      vscode-langservers-extracted

      marksman
    ];

    plugins = with pkgs.vimPlugins; [
      lazy-nvim
    ];

    extraLuaConfig =
      let
        plugins = with pkgs.vimPlugins; [
          # Rust
          nvim-dap
          crates-nvim
          rust-tools-nvim
          neotest-rust
          neotest
          # LazyVim
          LazyVim
          bufferline-nvim
          cmp-buffer
          cmp-nvim-lsp
          cmp-path
          cmp_luasnip
          conform-nvim
          dashboard-nvim
          dressing-nvim
          flash-nvim
          friendly-snippets
          gitsigns-nvim
          indent-blankline-nvim
          clangd_extensions-nvim
          lualine-nvim
          neo-tree-nvim
          nvim-web-devicons
          neoconf-nvim
          neodev-nvim
          noice-nvim
          nui-nvim
          nvim-cmp
          nvim-lint
          nvim-lspconfig
          nvim-notify
          nvim-spectre
          nvim-treesitter
          nvim-treesitter-context
          nvim-treesitter-textobjects
          nvim-ts-autotag
          nvim-ts-context-commentstring
          nvim-web-devicons
          persistence-nvim
          plenary-nvim
          telescope-fzf-native-nvim
          telescope-nvim
          todo-comments-nvim
          tokyonight-nvim
          trouble-nvim
          vim-illuminate
          vim-startuptime
          which-key-nvim
          { name = "LuaSnip"; path = luasnip; }
          { name = "mini.ai"; path = mini-nvim; }
          { name = "mini.bufremove"; path = mini-nvim; }
          { name = "mini.comment"; path = mini-nvim; }
          { name = "mini.indentscope"; path = mini-nvim; }
          { name = "mini.pairs"; path = mini-nvim; }
          { name = "mini.surround"; path = mini-nvim; }
        ];
        mkEntryFromDrv = drv:
          if lib.isDerivation drv then
            { name = "${lib.getName drv}"; path = drv; }
          else
            drv;
        lazyPath = pkgs.linkFarm "lazy-plugins" (builtins.map mkEntryFromDrv plugins);
      in
      ''
        require("lazy").setup({
          defaults = {
            lazy = true,
          },
          dev = {
            -- reuse files from pkgs.vimPlugins.*
            path = "${lazyPath}",
            patterns = { "." },
            -- fallback to download
            fallback = true,
          },
          spec = {
            -- add LazyVim and import its plugins
            { "LazyVim/LazyVim", import = "lazyvim.plugins" },
            -- import any extras modules here
            { import = "lazyvim.plugins.extras.lang.typescript" },
            { import = "lazyvim.plugins.extras.coding.copilot" },
            { import = "lazyvim.plugins.extras.lang.json" },
            { import = "lazyvim.plugins.extras.lang.python" },
            { import = "lazyvim.plugins.extras.lang.markdown" },
            { import = "lazyvim.plugins.extras.lang.rust" },
            { import = "lazyvim.plugins.extras.linting.eslint" },
            { import = "lazyvim.plugins.extras.lang.clangd" },
            { import = "lazyvim.plugins.extras.lang.cmake" },
            { import = "lazyvim.plugins.extras.formatting.prettier" },
            { import = "lazyvim.plugins.extras.util.mini-hipatterns" },
            -- The following configs are needed for fixing lazyvim on nix
            -- force enable telescope-fzf-native.nvim
            { "nvim-telescope/telescope-fzf-native.nvim", enabled = true },
            -- disable mason.nvim, use programs.neovim.extraPackages
            { "williamboman/mason-lspconfig.nvim", enabled = false },
            { "williamboman/mason.nvim", enabled = false },
            -- import/override with your plugins
            { import = "plugins" },
            -- treesitter handled by xdg.configFile."nvim/parser", put this line at the end of spec to clear ensure_installed
            { "nvim-treesitter/nvim-treesitter", opts = { ensure_installed = {} } },
          },
        })

        -- disable swap files
        vim.opt.swapfile = false
      '';
  };

  zellij = {
    enable = true;
    enableFishIntegration = true;
  };

  starship = {
    enable = true;
    enableFishIntegration = true;
  };

  ssh = {
    enable = true;

    extraConfig = lib.mkMerge [
      ''
        Host github.com
          Hostname github.com
          IdentitiesOnly yes
      ''
      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
        ''
          IdentityFile /home/${user}/.ssh/id_github
        '')
      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
        ''
          IdentityFile /Users/${user}/.ssh/id_github
        '')
    ];
  };
}
