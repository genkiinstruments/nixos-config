{
  flake,
  ...
}:
{
  imports = [
    flake.modules.home.default
    flake.modules.home.mvim
  ];

  # Enable mvim with home-manager integration and custom config path
  programs.mvim = {
    enable = true;
    configPath = "/private/etc/nixos-config"; # Adjust this path as needed
    appName = "mvim";
  };

  programs.git = {
    userEmail = "olafur@genkiinstruments.com";
    userName = "multivac61";
    extraConfig.github.user = "multivac61";
  };
}
