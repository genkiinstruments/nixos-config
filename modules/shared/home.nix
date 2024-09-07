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
        n = ''nvim -c "Telescope frecency workspace=CWD"'';
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
        ];
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
        nixfmt-rfc-style

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
        # nodePackages.eslint
        tailwindcss-language-server
        (pkgs.vimUtils.buildVimPlugin {
          pname = "tailwindcss-colorizer-cmp";
          version = "1.0";
          src = pkgs.fetchFromGitHub {
            owner = "roobert";
            repo = "tailwindcss-colorizer-cmp.nvim";
            rev = "3d3cd95e4a4135c250faf83dd5ed61b8e5502b86";
            hash = "sha256-PIkfJzLt001TojAnE/rdRhgVEwSvCvUJm/vNPLSWjpY=";
          };
        })

        elixir

        # Other
        marksman
        shfmt
        markdownlint-cli2

        markdown-oxide

        # sql
        sqlfluff
        sqlite
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
            neotest
            neotest-elixir
            neotest-plenary

            # Python
            neotest-python

            neotest-zig
            vim-tmux-navigator

            # Markdown
            render-markdown
            markdown-preview-nvim
            vim-markdown-toc
            vim-markdown
            conform-nvim

            zen-mode-nvim
            twilight-nvim

            # SQLITE and dadbod 👨
            vim-dadbod
            vim-dadbod-ui
            vim-dadbod-completion
            edgy-nvim

            # LazyVim
            LazyVim
            cmp-buffer
            cmp-nvim-lsp
            cmp-path
            dashboard-nvim
            dressing-nvim
            flash-nvim
            friendly-snippets
            nvim-snippets
            gitsigns-nvim
            indent-blankline-nvim
            clangd_extensions-nvim
            cmake-tools-nvim
            lualine-nvim
            oil-nvim
            neoconf-nvim
            nvim-nio
            none-ls-nvim
            lazydev-nvim
            noice-nvim
            nui-nvim
            calendar-vim
            nvim-cmp
            nvim-lint
            nvim-lspconfig
            nvim-notify
            grug-far-nvim
            nvim-treesitter
            nvim-treesitter-context
            nvim-treesitter-textobjects

            telescope-frecency-nvim
            sqlite-lua

            nvim-ts-autotag
            nvim-ts-context-commentstring
            ts-comments-nvim
            {
              name = "catppuccin";
              path = catppuccin-nvim;
            }
            tokyonight-nvim
            telescope-fzf-native-nvim
            null-ls-nvim
            nvim-web-devicons
            persistence-nvim
            plenary-nvim
            telescope-nvim
            todo-comments-nvim
            trouble-nvim
            vim-illuminate
            vim-startuptime
            which-key-nvim
            undotree
            cloak-nvim
            SchemaStore-nvim
            {
              name = "mini.ai";
              path = mini-nvim;
            }
            {
              name = "mini.diff";
              path = mini-nvim;
            }
            {
              name = "mini.icons";
              path = mini-nvim;
            }
            {
              name = "mini.move";
              path = mini-nvim;
            }
            {
              name = "mini.hipatterns";
              path = mini-nvim;
            }
            {
              name = "mini.misc";
              path = mini-nvim;
            }
            {
              name = "mini.bufremove";
              path = mini-nvim;
            }
            {
              name = "mini.comment";
              path = mini-nvim;
            }
            {
              name = "mini.indentscope";
              path = mini-nvim;
            }
            {
              name = "mini.pairs";
              path = mini-nvim;
            }
            {
              name = "mini.surround";
              path = mini-nvim;
            }
            (pkgs.vimUtils.buildVimPlugin {
              pname = "luvit-meta";
              src = pkgs.fetchFromGitHub {
                owner = "Bilal2453";
                repo = "luvit-meta";
                rev = "ce76f6f6cdc9201523a5875a4471dcfe0186eb60";
                hash = "sha256-zAAptV/oLuLAAsa2zSB/6fxlElk4+jNZd/cPr9oxFig=";
              };
              version = "2024-07-30";
            })
            (pkgs.vimUtils.buildVimPlugin {
              pname = "venv-selector";
              src = pkgs.fetchFromGitHub {
                owner = "linux-cultist";
                repo = "venv-selector.nvim";
                rev = "f16c25bf16ac6e8bbdbcc9e9b3a1a00729d00c99";
                hash = "sha256-zAAptV/oLuLAAsa2zSB/6fxlElk4+jNZd/cPr9oxFig=";
              };
              version = "2024-06-06";
            })
          ];
          mkEntryFromDrv =
            drv:
            if lib.isDerivation drv then
              {
                name = "${lib.getName drv}";
                path = drv;
              }
            else
              drv;
          lazyPath = pkgs.linkFarm "lazy-plugins" (builtins.map mkEntryFromDrv plugins);
          pythonPlusDot =
            pkgs.runCommandCC "python-plus-dot"
              {
                pname = "python-plus-dot";
                executable = true;
                preferLocalBuild = true;
                nativeBuildInputs = [ pkgs.makeBinaryWrapper ];
              }
              ''
                makeBinaryWrapper ${pkgs.coreutils}/bin/env $out \
                  --add-flags python \
                  --prefix PYTHONPATH : .
              '';
        in
        # lua
        ''
          require("lazy").setup({
            defaults = {
              lazy = true,
            },
            dev = {
              -- reuse files from pkgs.vimPlugins.*
              path = "${lazyPath}",
              patterns = { "." },
              fallback = true, -- fallback to download
            },
            spec = {
              -- add LazyVim and import its plugins
              { "LazyVim/LazyVim", import = "lazyvim.plugins", opts = { colorscheme = "catppuccin-mocha"}},
              { import = "lazyvim.plugins.extras.test.core" },
              -- import any extras modules here
              { import = "lazyvim.plugins.extras.lang.elixir" },
              { import = "lazyvim.plugins.extras.lang.nix" },
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
                -- Lua
              { import = "lazyvim.plugins.extras.lang.sql" },
              { import = "lazyvim.plugins.extras.coding.mini-surround" },
              { import = "lazyvim.plugins.extras.editor.mini-diff" },
              { import = "lazyvim.plugins.extras.editor.mini-move" },
              { import = "lazyvim.plugins.extras.lang.tailwind" },
              { import = "lazyvim.plugins.extras.util.mini-hipatterns" }, -- Tailwind 
              {
                "nvim-telescope/telescope-frecency.nvim",
                lazy = false,
                config = function()
                  require("telescope").load_extension "frecency"
                  vim.keymap.set("n", "<Leader>f.", function() require("telescope").extensions.frecency.frecency { workspace = "CWD", } end, { desc = "Find files in CWD by frecency" })
                  vim.keymap.set("n", "<Leader>fF", function() require("telescope").extensions.frecency.frecency {  } end, { desc = "Find files by frecency" })
                end,
              },
              {
                "folke/noice.nvim",
                opts = {
                  lsp = {
                    hover = {
                      -- Set not show a message if hover is not available, ex: shift+k on Typescript code
                      silent = true,
                    },
                  },
                },
              },
              { "alexghergh/nvim-tmux-navigation", lazy = false, },
              -- The following configs are needed for fixing lazyvim on nix: disable mason.nvim, use programs.neovim.extraPackages
              { "williamboman/mason-lspconfig.nvim", enabled = false },
              { "williamboman/mason.nvim", enabled = false },
              { "nvim-neo-tree/neo-tree.nvim", enabled = false },
              { "akinsho/bufferline.nvim", enabled = false },
              { "nvimdev/dashboard-nvim", enabled = false },
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

          vim.opt.spell = false

          -- Disable syntax highlighting for .fish files
          vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
            pattern = "*.fish",
            callback = function()
              vim.cmd("syntax off")
            end,
          })

          -- Don't show tabs
          vim.cmd [[ set showtabline=0 ]]

          -- lsp
          -- `on_attach` callback will be called after a language server
          -- instance has been attached to an open buffer with matching filetype
          -- here we're setting key mappings for hover documentation, goto definitions, goto references, etc
          -- you may set those key mappings based on your own preference
          local on_attach = function(client, bufnr)
            local opts = { noremap=true, silent=true }

            vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
            vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
            vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
            vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
            vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
            vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
            vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>cr', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
            vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
            vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>cf', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
            vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>cd', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
            vim.api.nvim_buf_set_keymap(bufnr, 'n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
            vim.api.nvim_buf_set_keymap(bufnr, 'n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
          end

          -- auto format on save
          vim.cmd [[autocmd BufWritePre *.nix lua vim.lsp.buf.format()]]

          require('lspconfig').elixirls.setup {
            cmd = { "${pkgs.elixir-ls}/lib/language_server.sh" },
            on_attach = on_attach
          }

          require('lspconfig').emmet_ls.setup({
            capabilities = capabilities,
            filetypes = { "html", "css", "elixir", "eelixir", "heex" },
          })
        '';
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
        {
          plugin = tmux-floax;
          extraConfig = ''
            set -g @floax-bind '/'
            set -g @floax-bind 'C-/'
            set -g @floax-bind '-n C-/'
            set -g @floax-session-name 'floax'
            set -g @floax-text-color 'white'
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

  # https://github.com/nvim-treesitter/nvim-treesitter#i-get-query-error-invalid-node-type-at-position
  xdg.configFile."nvim/parser".source =
    with pkgs;
    let
      parsers = symlinkJoin {
        name = "treesitter-parsers";
        paths =
          (vimPlugins.nvim-treesitter.withPlugins (
            p: with p; [
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

              elixir
              heex
              eex

              sql
            ]
          )).dependencies;
      };
    in
    "${parsers}/parser";

  xdg.configFile."nvim" = {
    recursive = true;
    source = ../shared/config/nvim;
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
