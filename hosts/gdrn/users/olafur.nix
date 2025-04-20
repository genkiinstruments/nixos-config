{ flake, ... }:
{
  imports = [
    flake.homeModules.default
    flake.homeModules.nvim
  ];

  programs.ssh = {
    controlMaster = "auto";
    controlPath = "/tmp/ssh-%u-%r@%h:%p";
    controlPersist = "1800";
    forwardAgent = true;
    addKeysToAgent = "yes";
    serverAliveInterval = 900;
  };
}
