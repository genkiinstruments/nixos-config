{ config, pkgs, ... }:

let
  user = "olafur";
in
{
  imports = [
   ./dock
  ];

  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.fish;
  };

  homebrew.enable = true;
  homebrew.casks = pkgs.callPackage ./casks.nix { };

  # These app IDs are from using the mas CLI app
  # mas = mac app store
  # https://github.com/mas-cli/mas
  #
  # $ nix shell nixpkgs#mas
  # $ mas search <app name>
  #
  homebrew.masApps = {
    # "1password" = 1333542190;
    # "wireguard" = 1451685025;
  };

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    users.${user} = { pkgs, config, lib, ... }: {
      home.enableNixpkgsReleaseCheck = false;
      home.packages = pkgs.callPackage ./packages.nix { };
      home.stateVersion = "23.05";

      xdg.enable = true;

      # https://github.com/nvim-treesitter/nvim-treesitter#i-get-query-error-invalid-node-type-at-position
      home.file.".config/nvim/parser".source =
        let
          parsers = pkgs.symlinkJoin {
            name = "treesitter-parsers";
            paths = (pkgs.vimPlugins.nvim-treesitter.withPlugins (plugins: with plugins; [
              bash
              c
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
              markdown_inline
              python
              query
              regex
              toml
              tsx
              typescript
              vim
              vimdoc
              yaml

              c
              lua

              # Nix
              nix

              # Rust
              rust
              toml
              kdl

              # Svelte
              svelte
              prisma
              sql

              # Tailwind
              # TODO: tailwindcss

              # Treesitter
              regex
              bash
              markdown
              markdown_inline
            ])).dependencies;
          };
        in
        "${parsers}/parser";

      # Normal LazyVim config here, see https://github.com/LazyVim/starter/tree/main/lua
      home.file.".config/nvim/lua".source = ../shared/config/nvim/lua;
      
      # Zellij stuff. Currently broken
      home.file.".config/zellij/config.kdl".source = ../shared/config/zellij/config.kdl;
      home.file.".config/zellij/layouts/default.kdl".source = ../shared/config/zellij/layouts/default.kdl;

      # Hyper-key config
      home.file.".config/karabiner/karabiner.json".source = ./config/karabiner/karabiner.json;
      
      # Raycast
      home.file.".config/raycast" = { recursive = true; source = config/raycast; };

      # Lazyvim plugins
      home.file."nvim/lua/plugins/c.lua".source = ./config/nvim/lua/plugins/c.lua;
      home.file."nvim/lua/plugins/eslint.lua".source = ./config/nvim/lua/plugins/eslint.lua;
      home.file."nvim/lua/plugins/neo-tree.lua".source = ./config/nvim/lua/plugins/neo-tree.lua;
      home.file."nvim/lua/plugins/nix.lua".source = ./config/nvim/lua/plugins/nix.lua;
      home.file."nvim/lua/plugins/rust.lua".source = ./config/nvim/lua/plugins/rust.lua;
      home.file."nvim/lua/plugins/sql.lua".source = ./config/nvim/lua/plugins/sql.lua;
      home.file."nvim/lua/plugins/supertab.lua".source = ./config/nvim/lua/plugins/supertab.lua;
      home.file."nvim/lua/plugins/svelte.lua".source = ./config/nvim/lua/plugins/svelte.lua;
      home.file."nvim/lua/plugins/tailwind.lua".source = ./config/nvim/lua/plugins/tailwind.lua;
      home.file."nvim/lua/plugins/telescope.lua".source = ./config/nvim/lua/plugins/telescope.lua;
      home.file."nvim/lua/plugins/treesitter.lua".source = ./config/nvim/lua/plugins/treesitter.lua;
  
      programs = { } // import ../shared/home-manager.nix { inherit config pkgs lib; };

      # Marked broken Oct 20, 2022 check later to remove this https://github.com/nix-community/home-manager/issues/3344
      manual.manpages.enable = false;
    };
  };

  # Fully declarative dock using the latest from Nix Store
  local.dock.enable = true;
  local.dock.entries = [
    { path = "${pkgs.alacritty}/Applications/Alacritty.app/"; }
    {
      path = "${config.users.users.${user}.home}/.local/share/";
      section = "others";
      options = "--sort name --view grid --display folder";
    }
    {
      path = "${config.users.users.${user}.home}/.local/share/downloads";
      section = "others";
      options = "--sort name --view grid --display stack";
    }
  ];

}
