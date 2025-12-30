{
  flake,
  lib,
  ...
}:
{
  imports = [
    flake.modules.home.default
    flake.modules.home.olafur
    flake.modules.home.niri
  ];

  catppuccin.gtk.icon.enable = true;

  # GTK dark theme (catppuccin gtk was archived, using Adwaita dark)
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
    };
    # catppuccin-papirus-folders is Linux-only (override in Linux hosts)
    icon.enable = lib.mkForce false;
  };

  # Prefer dark mode for all apps
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

  # Qt dark theme
  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style.name = "kvantum";
  };
}
