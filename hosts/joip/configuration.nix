{
  inputs,
  lib,
  flake,
  ...
}:
{
  imports = [
    inputs.srvos.nixosModules.server
    inputs.srvos.nixosModules.mixins-terminfo
    inputs.srvos.nixosModules.mixins-systemd-boot
    inputs.srvos.nixosModules.mixins-trusted-nix-caches
    inputs.disko.nixosModules.disko
    inputs.agenix.nixosModules.default
    inputs.nixos-facter-modules.nixosModules.facter
    flake.modules.shared.default
    flake.nixosModules.common
    ./disk-config.nix
  ];

  networking.hostName = "joip";

  system.stateVersion = "23.05"; # Did you read the comment?

  facter.reportPath = ./facter.json;

  services.home-assistant = {
    enable = true;
    openFirewall = true;

    extraComponents = [
      "apple_tv"
      "brother"
      "default_config"
      "denonavr"
      "esphome"
      "file"
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
      "ssdp"
      "unifi"
      "unifiprotect"
      "upnp"
      "vacuum"
      "weather"
      "webostv"
      "wled"
      "xiaomi_miio"
      "zeroconf"
    ];
    extraPackages =
      python3Packages: with python3Packages; [
        pip
        gtts
        dateutil
        aiohomekit
        pyatv
        getmac
        async-upnp-client
      ];
    # Includes dependencies for a basic setup: https://www.home-assistant.io/integrations/default_config/
    config.default_config = { };

    config.zeroconf = { };
    config.homekit.filter.include_domains = [ "light" ];
    config.logger.default = "info";
  };
  services.avahi = {
    enable = true;
    reflector = true;
  };

  services = {
    mosquitto.enable = true;
    zigbee2mqtt = {
      enable = true;

      settings = {
        homeassistant = true;
        mqtt = {
          server = "mqtt://localhost:1883";
        };
        serial = {
          port = "/dev/serial/by-id/usb-SMLIGHT_SMLIGHT_SLZB-06M_d4990940d2acef11a8c0904ba8793231-if00-port0";
          baudrate = 115200;
          adapter = "ember";
        };
        frontend = {
          host = "0.0.0.0";
          port = 8453;
        };
        advanced = {
          homeassistant_legacy_entity_attributes = false;
          homeassistant_legacy_triggers = false;
          legacy_api = false;
          legacy_availability_payload = false;
        };
        device_options.legacy = false;
      };
    };
  };

  networking.useHostResolvConf = lib.mkForce false;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      80
      111
      443
      1400
      1883
      2049
      4000
      4001
      4002
      5580
      8034
      8123
      8453
      20048
      21063
      21064
      51827
    ];
    allowedTCPPortRanges = [
      {
        from = 21064;
        to = 21067;
      }
    ];
    allowedUDPPorts = [
      111
      1900
      2049
      4000
      4001
      4002
      5353
      5683
      20048
      21324
    ];
  };
}
