{ pkgs, lib, ... }:
{
  imports =
    [
      ./disk-config.nix
      ./hardware-configuration.nix
      ../../modules/shared
      ../../modules/shared/servarr
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.useDHCP = lib.mkDefault true;

  networking.networkmanager.enable = true;

  services.openssh.openFirewall = true;
  programs.ssh.startAgent = true;

  services.home-assistant = {
    enable = true;
    openFirewall = true;

    extraComponents = [
      "apple_tv"
      "brother"
      "default_config"
      "denonavr"
      "esphome"
      "homekit"
      "homekit_controller"
      "icloud"
      "ipp"
      "jellyfin"
      "lovelace"
      "media_player"
      "met"
      "mjpeg"
      "mqtt"
      "otbr"
      "prusalink"
      "radarr"
      "ring"
      "roomba"
      "snmp"
      "sonarr"
      "sonos"
      "spotify"
      "unifi"
      "unifiprotect"
      "upnp"
      "vacuum"
      "weather"
      "webostv"
      "wled"
      "xiaomi_miio"
    ];
    extraPackages = python3Packages: with python3Packages; [ pip gtts dateutil aiohomekit pyatv getmac async-upnp-client ];
    config = {
      # Includes dependencies for a basic setup: https://www.home-assistant.io/integrations/default_config/
      default_config = { };
    };
  };

  services.avahi = {
    enable = true;
    reflector = true;
    openFirewall = true;
  };

  networking.useHostResolvConf = lib.mkForce false;
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedTCPPorts = [
      80
      443
      1400
      5580
      8123
      21063
      21064
      51827
      111
      2049
      4000
      4001
      4002
      20048
    ];
    allowedUDPPorts = [
      1900
      5353
      5683
      21324
      111
      2049
      4000
      4001
      4002
      20048
    ];

  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
