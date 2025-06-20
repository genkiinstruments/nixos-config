{ pkgs, lib, ... }:
{
  programs.fish.enable = true; # Otherwise our shell won't be installed correctly
  environment.shells = with pkgs; [ fish ];
  home-manager.backupFileExtension = "backup";
  environment.variables.SHELL = "${pkgs.fish}/bin/fish";

  # Enable mvim system package by default (can be overridden per-system)
  programs.mvim.enableSystemPackage = lib.mkDefault true;
}
