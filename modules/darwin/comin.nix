{ inputs, ... }:
{
  imports = [
    inputs.comin.darwinModules.comin
    inputs.agenix.nixosModules.default
  ];

  services.comin = {
    enable = true;
    remotes = [
      {
        name = "origin";
        url = "https://github.com/genkiinstruments/nixos-config";
        branches.main.name = "main";
      }
    ];
  };
}
