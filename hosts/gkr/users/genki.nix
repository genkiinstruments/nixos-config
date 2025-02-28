{ flake, ... }:
{
  imports = [ flake.homeModules.default ];
  programs.atuin.settings.daemon.enabled = true;
}
