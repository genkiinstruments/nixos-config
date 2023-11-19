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

  # These app IDs are from using the mas (mac app store) CLI app
  # https://github.com/mas-cli/mas
  #
  # $ nix shell nixpkgs#mas
  # $ mas search <app name>
  homebrew.masApps = {
    "Keynote" = 409183694;
    "ColorSlurp" = 1287239339;
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

              # Nix
              nix

              # Rust
              rust
              kdl

              # Svelte
              svelte
              sql

              # Tailwind
              # TODO: tailwindcss
            ])).dependencies;
          };
        in
        "${parsers}/parser";

      # Normal LazyVim config here, see https://github.com/LazyVim/starter/tree/main/lua
      home.file.".config/nvim/lua" = { recursive = true; source = ../shared/config/nvim/lua; };

      home.file.".config/zellij/config.kdl".source = ../shared/config/zellij/config.kdl;
      home.file.".config/zellij/layouts/default.kdl".source = ../shared/config/zellij/layouts/default.kdl;
      home.file.".config/alacritty/alacritty.yml".source = ../shared/config/alacritty.yml;

      # Hyper-key config
      home.file.".config/karabiner/karabiner.json".source = ./config/karabiner/karabiner.json;

      # Raycast
      home.file.".config/raycast" = { recursive = true; source = config/raycast; };

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
