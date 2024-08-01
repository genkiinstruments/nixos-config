{ pkgs
, ...
}:
{
  disabledModules = [ "services/misc/homepage-dashboard.nix" ];
  imports = [
    "${pkgs}/nixos/modules/services/misc/homepage-dashboard.nix"
    ./joip.nix
  ];

  services.homepage-dashboard = {
    enable = true;
    openFirewall = true;
  };
}
