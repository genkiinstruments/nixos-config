{ pkgs, lib, host, user, ... }:
{
  imports = [
    ./base.nix
    ./zram.nix
    ../../modules/shared
    ../../modules/shared/home-manager.nix
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
  environment.systemPackages = with pkgs; [ procps ]; # I don´t know why this is needed?
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
    hostName = "${host}";
    firewall.enable = true;
    networkmanager.enable = lib.mkForce false;
    interfaces."wlan0".useDHCP = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
