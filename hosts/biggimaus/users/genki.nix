{ inputs, ... }:
{

  imports = [ inputs.self.homeModules.default ];
  programs.atuin.settings.daemon.enabled = true;
}
