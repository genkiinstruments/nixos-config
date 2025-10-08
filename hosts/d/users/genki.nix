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
  programs.git = {
    userEmail = "daniel@genkiinstruments.com";
    userName = "dingari";
    extraConfig.github.user = "dingari";
  };
}
