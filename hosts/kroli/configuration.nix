{
  inputs,
  flake,
  pkgs,
  ...
}:
{
  imports = [
    inputs.srvos.nixosModules.server
    inputs.srvos.nixosModules.mixins-terminfo
    inputs.srvos.nixosModules.mixins-systemd-boot
    inputs.srvos.nixosModules.mixins-trusted-nix-caches
    inputs.disko.nixosModules.disko
    inputs.nixos-facter-modules.nixosModules.facter
    flake.modules.shared.default
    flake.modules.shared.home-manager
    flake.modules.nixos.default
    ./disk-config.nix
  ];

  networking.hostName = "kroli";

  system.stateVersion = "23.05"; # Did you read the comment?

  facter.reportPath = ./facter.json;

  users.users.root.initialHashedPassword = "$y$j9T$xA3OJK4WPx3Gu80.nTV6h/$DsBKf3OL11/d9bOAQmSVbgf2H2Ue4FAwhPLcatF0tX3";

  security.sudo.wheelNeedsPassword = false;
  users.mutableUsers = false;
  # We are using zfs: https://github.com/atuinsh/atuin/issues/952#issuecomment-2199964530
  home-manager.users.olafur.programs.atuin.daemon.enable = true;
  users.users.olafur = {
    isNormalUser = true;
    description = "olafur";
    shell = pkgs.fish;
    hashedPassword = "$6$UIOsLjI24UeaovvG$SVVrXdpnepj/w1jhmYNdpPpmcgkcXsMBcAkqrcIL5yCCYDAkc/8kblyzuBLyK6PnJqR1JxZ7XtlWyCJwWhGrw.";
    extraGroups = [
      "networkmanager"
      "wheel"
      "plugdev"
      "dialout"
      "video"
      "inputs"
      "audio"
    ];
    openssh.authorizedKeys.keyFiles = [ "${flake}/authorized_keys" ];
  };
  nix.settings.trusted-users = [ "olafur" ];
}
