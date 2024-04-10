{ config, pkgs, user, name, email, ... }@inputs:

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

  homebrew = {
    enable = true;
    casks = [
      "shortcat"
      "raycast"
      "arc"
    ];
    # These app IDs are from using the mas (mac app store) CLI app https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    masApps = {
      "Keynote" = 409183694;
      "ColorSlurp" = 1287239339;
    };
    onActivation.cleanup = "zap";
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
        with pkgs;
        let
          parsers = symlinkJoin {
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
              nix
              rust
              ron
              toml
              kdl
              svelte
              sql
            ])).dependencies;
          };
        in
        "${parsers}/parser";

      # Normal LazyVim config here, see https://github.com/LazyVim/starter/tree/main/lua
      home.file.".config/nvim" = { recursive = true; source = ../shared/config/nvim; };
      home.file.".config/zellij" = { recursive = true; source = ../shared/config/zellij; };
      home.file.".config/ghostty/config".source = ../shared/config/ghostty/config;
      home.file.".config/alacritty/alacritty.toml".source = ../shared/config/alacritty.toml;
      home.file.".config/fish/themes/Catppuccin Mocha.theme".source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/catppuccin/fish/main/themes/Catppuccin%20Mocha.theme";
        sha256 = "MlI9Bg4z6uGWnuKQcZoSxPEsat9vfi5O1NkeYFaEb2I=";
      };

      # Hyper-key config
      home.file.".config/karabiner/karabiner.json".source = ./config/karabiner/karabiner.json;

      programs = { } // (import ../shared/home-manager.nix { inherit inputs; });
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
