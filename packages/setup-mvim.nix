{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "setup-mvim";
  text = ''
    if [ ! -d "$HOME/.nvim-config" ]; then
      ${pkgs.git}/bin/git clone git@github.com:multivac61/mvim.git "$HOME/.nvim-config"
    fi

    # Ensure ~/.config exists
    mkdir -p "$HOME/.config"

    # Remove existing symlink if it exists
    rm -f "$HOME/.config/nvim"

    # Create new symlink
    ln -s "$HOME/.nvim-config" "$HOME/.config/nvim"
  '';
}
