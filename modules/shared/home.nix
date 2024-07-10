{ pkgs, lib, config, ... }:
{
  home.enableNixpkgsReleaseCheck = false;
  home.stateVersion = "23.05";

  xdg.enable = true; # Needed for fish interactiveShellInit hack

  programs = {
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
            colorArg = "always";
            pager = "diff-so-fancy";
          };
        };
        gui = {
          language = "en";
          mouseEvents = false;
          sidePanelWidth = 0.3;
          mainPanelSplitMode = "flexible";
          showFileTree = true;
          nerdFontsVersion = "3";
          commitHashLength = 6;
          showDivergenceFromBaseBranch = "arrowAndNumber";
          skipDiscardChangeWarning = true;
        };
        quitOnTopLevelReturn = true;
        disableStartupPopups = true;
        promptToReturnFromSubprocess = false;
        # os = {
        #   edit = "nvim-remote";
        #   editAtLine = "{{editor}} +{{line}} {{filename}}";
        # };
      };
    };
    atuin = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        exit_mode = "return-query";
        keymap_mode = "auto";
        prefers_reduced_motion = true;
        enter_accept = true;
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
          '';
    };

    ssh.enable = true;

    git = {
      enable = true;
      ignores = [ "*.swp" ];
      lfs.enable = true;
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

    helix = {
      enable = true;
      extraPackages = with pkgs; [ marksman markdown-oxide ];
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
          esc = [ "collapse_selection" "keep_primary_selection" ];
        };
      };
    };
    neovim = {
      enable = true;
      defaultEditor = true;
      withPython3 = false;
      extraPackages = with pkgs; [
        # LazyVim
        lua-language-server
        stylua

        # Telescope
        ripgrep
        fd

        # workaround for nvim-spectre...
        (writeShellScriptBin "gsed" ''exec ${pkgs.gnused}/bin/sed "$@"'')

        # Nix
        nil
        nixpkgs-fmt

        # C
        clang-tools_18
        cppcheck
        include-what-you-use
        cmake-language-server
        neocmakelsp
        vscode-extensions.ms-vscode.cmake-tools

        # Rust
        rust-analyzer
        rustfmt
        cargo
        rustc
        clippy
        graphviz
        lldb
        taplo

        # Python
        ruff
        ruff-lsp
        pyright

        # Svelte
        svelte-language-server
        nodePackages.typescript-language-server
        nodePackages.prettier
        nodePackages.eslint
        tailwindcss-language-server
        vscode-langservers-extracted

        elixir
        elixir-ls

        # Other
        marksman
        shfmt
        markdownlint-cli2

        markdown-oxide
      ];

      plugins = [ pkgs.vimPlugins.lazy-nvim ];

      extraLuaConfig =
        let
          plugins = with pkgs.vimPlugins; [
            # Rust
            nvim-dap
            crates-nvim
            rust-tools-nvim
            neotest-rust
            rustaceanvim

            # Clojure
            conjure
            cmp-conjure

            # elixir
            neotest-elixir
            neotest
            neotest-plenary
            elixir-tools-nvim

            # Python
            neotest-python

            neotest-zig
            vim-tmux-navigator

            # Markdown
            headlines-nvim
            markdown-preview-nvim
            markdown-nvim
            vim-markdown-toc
            conform-nvim

            # LazyVim
            LazyVim
            cmp-buffer
            cmp-nvim-lsp
            cmp-path
            dashboard-nvim
            dressing-nvim
            flash-nvim
            friendly-snippets
            gitsigns-nvim
            indent-blankline-nvim
            clangd_extensions-nvim
            cmake-tools-nvim
            lualine-nvim
            oil-nvim
            neoconf-nvim
            nvim-nio
            neodev-nvim
            noice-nvim
            nui-nvim
            calendar-vim
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
            null-ls-nvim
            nvim-web-devicons
            persistence-nvim
            plenary-nvim
            telescope-zf-native-nvim
            telescope-nvim
            todo-comments-nvim
            catppuccin-nvim
            trouble-nvim
            vim-illuminate
            vim-startuptime
            which-key-nvim
            undotree
            cloak-nvim
            harpoon2
            { name = "mini.ai"; path = mini-nvim; }
            { name = "mini.misc"; path = mini-nvim; }
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
          pythonPlusDot = pkgs.runCommandCC "python-plus-dot"
            {
              pname = "python-plus-dot";
              executable = true;
              preferLocalBuild = true;
              nativeBuildInputs = [ pkgs.makeBinaryWrapper ];
            } ''
            makeBinaryWrapper ${pkgs.coreutils}/bin/env $out \
              --add-flags python \
              --prefix PYTHONPATH : .
          '';
        in
          /* lua */ ''
          vim.api.nvim_create_autocmd("VimEnter", {
            callback = vim.schedule_wrap(function(data)
              vim.print(vim.fn.isdirectory(data.file))
              if data.file == "" or vim.fn.isdirectory(data.file) ~= 0 then
                vim.print(data.file)
                require("oil").open()
              end
            end),
          })

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
              { "LazyVim/LazyVim", import = "lazyvim.plugins", opts = { rocks = { enabled = false; } } },
              -- import any extras modules here
              { import = "lazyvim.plugins.extras.test.core" },
              { import = "lazyvim.plugins.extras.lang.typescript" },
              { import = "lazyvim.plugins.extras.lang.json" },
              { import = "lazyvim.plugins.extras.lang.python",
                opts = {
                  adapters = {
                    ["neotest-python"] = {
                      -- Here you can specify the settings for the adapter, i.e.
                      runner = "pytest",
                      python = "${pythonPlusDot}",
                    },
                  },
                } },
              { import = "lazyvim.plugins.extras.lang.markdown" },
              { import = "lazyvim.plugins.extras.lang.rust" },
              { import = "lazyvim.plugins.extras.linting.eslint" },
              { import = "lazyvim.plugins.extras.coding.mini-surround" },
              { import = "lazyvim.plugins.extras.editor.mini-diff" },
              { import = "lazyvim.plugins.extras.editor.mini-move" },
              { import = "lazyvim.plugins.extras.lsp.none-ls" },
              { import = "lazyvim.plugins.extras.lang.clangd" },
              { import = "lazyvim.plugins.extras.formatting.prettier" },
              { import = "lazyvim.plugins.extras.util.mini-hipatterns" },
              -- The following configs are needed for fixing lazyvim on nix
              -- force enable telescope-fzf-native.nvim
              -- { "nvim-telescope/telescope-zf-native.nvim", enabled = true },
              -- disable mason.nvim, use programs.neovim.extraPackages
              { "williamboman/mason-lspconfig.nvim", enabled = false },
              { "williamboman/mason.nvim", enabled = false },
              { "nvim-neo-tree/neo-tree.nvim", enabled = false },
              { "akinsho/bufferline.nvim", enabled = false },
              -- import/override with your plugins
              { import = "plugins" },
              -- treesitter handled by xdg.configFile."nvim/parser", put this line at the end of spec to clear ensure_installed
              { "nvim-treesitter/nvim-treesitter", opts = function(_, opts) opts.ensure_installed = {} end, },
            },
          })

          -- Disable swap files
          vim.opt.swapfile = false

          --  https://old.reddit.com/r/neovim/comments/1ajpdrx/lazyvim_weird_live_grep_root_dir_functionality_in/
          -- Type :LazyRoot in the directory you're in and that will show you the root_dir that will be used for the root_dir search commands. The reason you're experiencing this behavior is because your subdirectories contain some kind of root_dir pattern for the LSP server attached to the buffer.
          vim.g.root_spec = { "cwd" }

          -- Set colorscheme
          vim.cmd.colorscheme "catppuccin-mocha"

          -- Disable syntax highlighting for .fish files
          vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
            pattern = "*.fish",
            callback = function()
              vim.cmd("syntax off")
            end,
          })

          -- Don't show tabs
          vim.cmd [[ set showtabline=0 ]]

          -- https://github.com/nvim-telescope/telescope.nvim/issues/855
          require("telescope").setup{
            pickers = {
              find_files = {
                find_command = { 'rg', '--files', '--iglob', '!.git', '--hidden' },
              },
              grep_string = {
                additional_args = {"--hidden"}
              },
              live_grep = {
                additional_args = {"--hidden"}
              },
            },
          }
        '';
    };

    tmux = {
      enable = true;
      plugins = with pkgs.tmuxPlugins; [
        vim-tmux-navigator
        yank
        fzf-tmux-url
      ];
      sensibleOnTop = true;
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

  # https://github.com/nvim-treesitter/nvim-treesitter#i-get-query-error-invalid-node-type-at-position
  home.file.".config/nvim/parser".source =
    with pkgs;
    let
      parsers = symlinkJoin
        {
          name = "treesitter-parsers";
          paths = (vimPlugins.nvim-treesitter.withPlugins (p: with p; [
            bash
            c
            cpp
            cmake
            diff
            html
            javascript
            jsdoc
            json
            jsonc
            lua
            luadoc
            luap
            markdown
            markdown-inline
            python
            query
            regex
            toml
            tsx
            typescript
            vim
            vimdoc
            yaml
            nix
            ninja
            rst

            zig

            rust
            ron
            kdl

            svelte
            sql
            elixir
            heex
            eex
          ])).dependencies;
        };
    in
    config.lib.file.mkOutOfStoreSymlink "${parsers}/parser";

  home.file.".config/nvim" = { recursive = true; source = config.lib.file.mkOutOfStoreSymlink ../shared/config/nvim; };
  home.file.".config/ghostty/config".source = config.lib.file.mkOutOfStoreSymlink ../shared/config/ghostty/config;
  home.packages = with pkgs; [
    wget
    zip
    moonlight-qt
    magic-wormhole-rs
    gh
    nb

    # for sesh
    gh-dash
    sesh
    fzf
    gum

    btop
    cachix
    ripgrep
    fd
    xsel # for lazygit copy/paste stuff to clipboard
  ];
}
