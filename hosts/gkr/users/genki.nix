{ flake, ... }:
{
  imports = [ flake.modules.home.default ];

  programs.git = {
    userEmail = "olafur@genkiinstruments.com";
    userName = "multivac61";
    extraConfig.github.user = "multivac61";
  };
}
