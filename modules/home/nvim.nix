{ flake, ... }:
{
  pkgs,
  config,
  ...
}:
let
  nvim-lsp-packages = flake.lib.nvim-lsp-packages { inherit pkgs; };
  treesitter-grammars = flake.lib.treesitter-grammars { inherit pkgs; };
  neovim = flake.lib.neovim { inherit pkgs; };
in
{
  home.packages = nvim-lsp-packages ++ [
    neovim
    pkgs.git
  ];

  # home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/nixos-config/home/nvim";
  xdg.dataFile."nvim/site/parser".source = treesitter-grammars;

  # Use Home Manager's dag (directed acyclic graph) system to ensure proper ordering
  home.activation.nvimSetup = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    echo "Setting up Neovim configuration..."

    # Create the directory if it doesn't exist
    mkdir -p "${config.xdg.configHome}/nvim"

    # Write the treesitter revision
    echo "${treesitter-grammars.rev}" > "${config.xdg.configHome}/nvim/treesitter-rev"

    # Update plugins if needed
    XDG_CONFIG_HOME=''${XDG_CONFIG_HOME:-$HOME/.config}
    NVIM_APPNAME=''${NVIM_APPNAME:-nvim}
    if [[ -f $XDG_CONFIG_HOME/$NVIM_APPNAME/lazy-lock.json ]]; then
      if ! grep -q "${treesitter-grammars.rev}" "$XDG_CONFIG_HOME/$NVIM_APPNAME/lazy-lock.json"; then
        ${neovim}/bin/nvim --headless "+Lazy! update" +qa
      fi
    fi
  '';
}
