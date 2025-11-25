{ inputs, hostName, ... }:
{
  imports = [
    inputs.comin.nixosModules.comin
  ];

  # comin needs this to be set explicitly
  networking.hostName = hostName;

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
