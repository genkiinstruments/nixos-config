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

  programs.ssh = {
    controlMaster = "auto";
    controlPath = "/tmp/ssh-%u-%r@%h:%p";
    controlPersist = "1800";
    forwardAgent = true;
    addKeysToAgent = "yes";
    serverAliveInterval = 900;
  };
}
