{
  flake,
  perSystem,
  lib,
  ...
}:
{
  imports = [ flake.modules.home.default ];

  home.sessionVariables.EDITOR = lib.mkDefault "mvim";
  home.packages = [ perSystem.self.mvim ];

  programs.git.settings = {
    user.email = "olafur@genkiinstruments.com";
    user.name = "multivac61";
    github.user = "multivac61";
  };
}
