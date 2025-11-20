{
  flake,
  ...
}:
{
  imports = [ flake.modules.home.default ];

  home.sessionVariables.MVIM_CONFIG_SOURCE = "/private/etc/nixos-config/home/nvim";

  programs.git.settings.user.email = "olafur@genkiinstruments.com";
  programs.git.settings.user.name = "multivac61";
  programs.git.settings.github.user = "multivac61";
}
