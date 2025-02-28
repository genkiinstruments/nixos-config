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

  homeDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin then # we assume that the username is set elsewhere
      if (config.home.username == "root") then "/var/root" else "/Users/${config.home.username}"
    else if (config.home.username == "root") then
      "/root"
    else
      "/home/${config.home.username}";
in
{
  home.packages = nvim-lsp-packages ++ [
    neovim
    pkgs.git
  ];

  # Keep the treesitter grammar source
  xdg.dataFile."nvim/site/parser".source = treesitter-grammars;

  # Use Home Manager's dag system to ensure proper ordering
  home.activation.nvimSetup = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    echo "Setting up Neovim configuration..."

    NVIM_CONFIG_PATH="${config.xdg.configHome}/nvim"

    # Check if the target exists and what type it is
    if [ -e "$NVIM_CONFIG_PATH" ]; then
      if [ -d "$NVIM_CONFIG_PATH" ] && [ ! -L "$NVIM_CONFIG_PATH" ]; then
        # It's a directory (not a symlink), exit with error
        echo "Error: $NVIM_CONFIG_PATH exists as a directory. Please remove it manually if you want to replace it with a symlink."
        exit 1
      elif [ -L "$NVIM_CONFIG_PATH" ]; then
        # It's a symlink, we can override it
        echo "Replacing existing symlink at $NVIM_CONFIG_PATH"
      else
        # It's a file, exit with error
        echo "Error: $NVIM_CONFIG_PATH exists as a file. Please remove it manually."
        exit 1
      fi
    fi

    # Create the symlink to your repository (will override existing symlink)
    ln -sf "${homeDirectory}/dev/nixos-config/home/nvim" "$NVIM_CONFIG_PATH"

    # Write the treesitter revision
    echo "${treesitter-grammars.rev}" > "$NVIM_CONFIG_PATH/treesitter-rev"

    # Update plugins if needed
    if [[ -f "$NVIM_CONFIG_PATH/lazy-lock.json" ]]; then
      if ! grep -q "${treesitter-grammars.rev}" "$NVIM_CONFIG_PATH/lazy-lock.json"; then
        ${neovim}/bin/nvim --headless "+Lazy! update" +qa
      fi
    fi
  '';
}
