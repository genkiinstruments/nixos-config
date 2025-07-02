{
  flake,
  ...
}:
{
  imports = [
    flake.modules.home.default
    flake.modules.home.mvim
    flake.modules.home.fish-ssh-agent
  ];

  # Enable mvim with home-manager integration and custom config path
  programs.mvim = {
    enable = true;
    configPath = "/private/etc/nixos-config"; # Adjust this path as needed
    appName = "mvim";
  };
  programs.fish.shellAliases.n = "nvim";

  programs.git = {
    userEmail = "olafur@genkiinstruments.com";
    userName = "multivac61";
    extraConfig.github.user = "multivac61";
  };

  # Configure SSH for clipboard sharing
  programs.ssh = {
    controlMaster = "auto";
    controlPath = "/tmp/ssh-%u-%r@%h:%p";
    controlPersist = "1800";
    forwardAgent = true;
    addKeysToAgent = "yes";
    serverAliveInterval = 900;
    enable = true;
  };
}
