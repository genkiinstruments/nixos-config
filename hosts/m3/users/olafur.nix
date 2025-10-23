{
  flake,
  ...
}:
{
  imports = [ flake.modules.home.default ];

  home.sessionVariables.MVIM_CONFIG_SOURCE = "/private/etc/nixos-config/home/nvim";

  programs.git.settings = {
    user.email = "olafur@genkiinstruments.com";
    user.name = "multivac61";
    github.user = "multivac61";
  };
}
