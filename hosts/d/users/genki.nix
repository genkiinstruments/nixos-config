{
  flake,
  ...
}:
{
  imports = [
    flake.modules.home.default
  ];

  programs.git.settings = {
    user.email = "daniel@genkiinstruments.com";
    user.name = "dingari";
    github.user = "dingari";
  };
  programs.zellij.enable = true;
  programs.zellij.enableFishIntegration = true;
}
