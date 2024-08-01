_:
{
  imports = [ ./joip.nix ];

  services.homepage-dashboard = {
    enable = true;
    openFirewall = true;
  };
}
