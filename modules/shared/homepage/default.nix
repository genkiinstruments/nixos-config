{ pkgs
, inputs
, ...
}:
{
  disabledModules = [ "services/misc/homepage-dashboard.nix" ];
  imports = [
    "${inputs.unstable}/nixos/modules/services/misc/homepage-dashboard.nix"
    ./joip.nix
  ];

  services.homepage-dashboard = {
    enable = true;
    openFirewall = true;
  };
}
