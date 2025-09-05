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

  programs.git = {
    userEmail = "olafur@genkiinstruments.com";
    userName = "multivac61";
    extraConfig.github.user = "multivac61";
  };
}
