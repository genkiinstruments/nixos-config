{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    (
      if pkgs.stdenv.isDarwin then
        inputs.stylix.darwinModules.stylix
      else
        inputs.stylix.nixosModules.stylix
    )
  ];

  stylix = {
    enable = true;
    autoEnable = true;
    # Using flake input to avoid IFD
    base16Scheme = "${inputs.base16-schemes}/base16/catppuccin-mocha.yaml";
    polarity = "dark";
    stylix.targets.fish.enable = false;
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
