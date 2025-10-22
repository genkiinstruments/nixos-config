{
  pkgs,
  flake,
  ...
}:
{
  imports = [
    flake.modules.home.default
  ];

  # NOTE: Use this to add packages available everywhere on your system
  home.packages = with pkgs; [
    zed-editor
  ];
  programs.git.settings = {
    user.email = "daniel@genkiinstruments.com";
    user.name = "dingari";
    github.user = "dingari";
  };
}
