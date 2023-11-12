{ config, pkgs, ... }:

let
  user = "olafur";
  # Define the content of your file as a derivation
  sharedFiles = import ../shared/files.nix { inherit config pkgs; };
  additionalFiles = import ./files.nix { inherit config pkgs; };
in
{
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
      home.file = lib.mkMerge [
        sharedFiles
        additionalFiles
      ];
      home.stateVersion = "23.05";

      xdg.enable = true;

      # https://github.com/nvim-treesitter/nvim-treesitter#i-get-query-error-invalid-node-type-at-position
      xdg.configFile."nvim/parser".source =
        let
          parsers = pkgs.symlinkJoin {
            name = "treesitter-parsers";
            paths = (pkgs.vimPlugins.nvim-treesitter.withPlugins (plugins: with plugins; [
              c
              lua
            ])).dependencies;
          };
        in
        "${parsers}/parser";

      # Normal LazyVim config here, see
      # https://github.com/LazyVim/starter/tree/main/lua
      xdg.configFile."nvim/lua".source = ../shared/config/nvim/lua;

      xdg.configFile."zellij/config.kdl".source = ../shared/config/zellij/config.kdl;
      xdg.configFile."zellij/layouts/default.kdl".source = ../shared/config/zellij/layouts/default.kdl;

      xdg.configFile."karabiner/karabiner.json".source = ./config/karabiner/karabiner.json;

      programs = { } // import ../shared/home-manager.nix { inherit config pkgs lib; };
    };
  };
}
