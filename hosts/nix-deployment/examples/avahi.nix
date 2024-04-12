{
  services.avahi = {
    openFirewall = true;
    nssmdns = true; # Allows software to use Avahi to resolve.
    enable = true;
    publish = {
      userServices = true;
      enable = true;
      addresses = true;
      workstation = true;
    };
  };
}

