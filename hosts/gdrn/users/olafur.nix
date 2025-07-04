{
  flake,
  perSystem,
  lib,
  ...
}:
{
  imports = [ flake.modules.home.default ];

  programs.fish.shellAliases.n = "mvim";
  home.sessionVariables.EDITOR = lib.mkDefault "mvim";
  home.packages = [ perSystem.self.mvim ];
  programs.git = {
    userEmail = "olafur@genkiinstruments.com";
    userName = "multivac61";
    extraConfig.github.user = "multivac61";
  };

  programs.ssh = {
    controlMaster = "auto";
    controlPath = "/tmp/ssh-%u-%r@%h:%p";
    controlPersist = "1800";
    forwardAgent = true;
    addKeysToAgent = "yes";
    serverAliveInterval = 900;
  };
}
