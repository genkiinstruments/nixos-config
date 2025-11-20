{ flake, ... }:
{
  imports = [ flake.modules.home.default ];

  programs.git.settings.user.email = "olafur@genkiinstruments.com";
  programs.git.settings.user.name = "multivac61";
  programs.git.settings.github.user = "multivac61";
}
