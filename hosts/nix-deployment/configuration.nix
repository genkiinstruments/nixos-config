{ pkgs, lib, host, user, ... }:
{
  imports = [
    ./base.nix
    ./zram.nix
    # ./yggdrasil.nix
    # ./motd.nix
    # ./avahi.nix
    # ./examples/gnome.nix
    # ./examples/plasma.nix
    # ./examples/xfce4.nix
    # ./examples/netdata.nix
    # ./examples/vaultwarden.nix
    # ./examples/led.nix
  ];
  environment.systemPackages = with pkgs; [
    vim
    git
    qrencode
    procps
  ];
  services.openssh.enable = true;
  systemd.services.display-manager.restartIfChanged = lib.mkForce true;
  users = {
    users.${user} = {
      password = "default";
      isNormalUser = true;
      extraGroups = [ "wheel" "gpio" ];
    };
    groups.gpio = { };
  };

  # Change permissions gpio devices
  services.udev.extraRules = ''
    SUBSYSTEM=="bcm2835-gpiomem", KERNEL=="gpiomem", GROUP="gpio",MODE="0660"
    SUBSYSTEM=="gpio", KERNEL=="gpiochip*", ACTION=="add", RUN+="${pkgs.bash}/bin/bash -c 'chown root:gpio  /sys/class/gpio/export /sys/class/gpio/unexport ; chmod 220 /sys/class/gpio/export /sys/class/gpio/unexport'"
    SUBSYSTEM=="gpio", KERNEL=="gpio*", ACTION=="add",RUN+="${pkgs.bash}/bin/bash -c 'chown root:gpio /sys%p/active_low /sys%p/direction /sys%p/edge /sys%p/value ; chmod 660 /sys%p/active_low /sys%p/direction /sys%p/edge /sys%p/value'"
  '';

  networking = {
    firewall.enable = true;
    networkmanager.enable = lib.mkForce false;
    networking.hostName = "${host}";
    interfaces."wlan0".useDHCP = true;
  };
}
