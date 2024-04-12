{ pkgs, ... }:
{
  systemd.services.turnOnLED = {
    description = "Turn on LED on GPIO pin 18";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.libgpiod}/bin/gpioset -c gpiochip0 18=1";
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
}
