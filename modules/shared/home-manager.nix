{ pkgs, perSystem, ... }:
{
  programs.fish.enable = true; # Otherwise our shell won't be installed correctly
  environment.shells = with pkgs; [ fish ];
  home-manager.backupFileExtension = "backup";
  environment.variables.SHELL = "${pkgs.fish}/bin/fish";
  
  # Add mvim by default to all systems
  environment.systemPackages = [ perSystem.self.mvim ];
}
