{
  pkgs,
  inputs,
  ...
}:
{
  # Platform-specific stylix module must be imported by the host or a platform module
  # Use flake.modules.darwin.stylix or flake.modules.nixos.stylix instead of this directly

  stylix = {
    enable = true;
    autoEnable = true;
    # Using flake input to avoid IFD
    base16Scheme = "${inputs.base16-schemes}/base16/catppuccin-mocha.yaml";
    polarity = "dark";
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.noto-fonts;
        name = "Noto Sans";
      };
      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };
      sizes = {
        terminal = 12;
        applications = 12;
      };
    };
  };
}
