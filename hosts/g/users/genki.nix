{
  flake,
  ...
}:
{
  imports = [ flake.modules.home.default ];

  programs.git.settings = {
    user.email = "olafur@genkiinstruments.com";
    user.name = "multivac61";
    github.user = "multivac61";
  };
}
