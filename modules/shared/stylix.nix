{ pkgs, inputs, ... }:
{
  stylix = {
    enable = true;
    autoEnable = true;
    # Using flake input to avoid IFD
    base16Scheme = "${inputs.base16-schemes}/base16/catppuccin-mocha.yaml";
    # Override base04 (surface2) which is too dim for fish_color_param
    # Using subtext1 instead for better readability
    override.base04 = "bac2de";
    # polarity = "dark";
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
