{
  services.vaultwarden = {
    enable = true;
    config = {
      signupsAllowed = true;
      rocketPort = 8222;
      rocketAddress = "0.0.0.0";
      rocketLog = "critical";
      disableIconDownload = true;
    };
  };
}
