{ pkgs, perSystem }:
pkgs.mkShell {
  packages =
    with pkgs;
    [
      nixfmt-rfc-style
      git
      nixos-anywhere
      nixos-rebuild
      age
      age-plugin-yubikey
      age-plugin-fido2-hmac
      (writeShellApplication {
        name = "setup-mvim";
        runtimeInputs = [ git ];
        text = ''
          repo_url="git@github.com:multivac61/mvim.git"
          config_dir="$HOME/.config/mvim"
          nvim_dir="$HOME/.config/nvim"

          # Clone the repository
          if [ ! -d "$config_dir" ]; then
            git clone "$repo_url" "$config_dir"
          else
            echo "Config directory already exists at $config_dir"
            exit 1
          fi

          # Ensure ~/.config exists
          mkdir -p "$HOME/.config"

          # Remove existing nvim config if it exists
          if [ -e "$nvim_dir" ]; then
            echo "Removing existing nvim config..."
            rm -rf "$nvim_dir"
          fi

          # Create symbolic link
          ln -s "$config_dir" "$nvim_dir"

          echo "Neovim config successfully set up!"
          echo "Config location: $config_dir"
          echo "Symlink created at: $nvim_dir"
        '';
      })
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      perSystem.nix-darwin.darwin-rebuild
    ];

  env = { };

  shellHook = ''export EDITOR=nvim'';
}
