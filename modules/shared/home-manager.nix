{ pkgs, ... }:
{
  programs.fish.enable = true; # Otherwise our shell won't be installed correctly
  environment.shells = with pkgs; [ fish ];
  home-manager.backupFileExtension = "backup";
  environment.variables.SHELL = "${pkgs.fish}/bin/fish";
}
