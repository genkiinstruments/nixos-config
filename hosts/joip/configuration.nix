{
  inputs,
  lib,
  flake,
  pkgs,
  config,
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
    flake.modules.nixos.default
    flake.modules.nixos.comin
    ./disk-config.nix
  ];

  system.stateVersion = "23.05";
  facter.reportPath = ./facter.json;

  services.home-assistant = {
    enable = true;
    openFirewall = true;

    extraComponents = [
      "apple_tv"
      "automation"
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
        (gtts.overridePythonAttrs (old: {
          postPatch = (old.postPatch or "") + ''
            substituteInPlace pyproject.toml \
              --replace-fail '"click >=7.1, <8.2",' '"click >=7.1",'
          '';
        }))
        python-dateutil
        pyatv
        getmac
        async-upnp-client
        aiohomekit
        python-otbr-api
      ];
    config.default_config = { };
    config.zeroconf = { };
    config.homekit = { };
    config.logger.default = "info";
    config."automation ui" = "!include automations.yaml";
  };

  services.avahi = {
    enable = true;
    reflector = true;
  };

  systemd.tmpfiles.rules = [
    "f ${config.services.home-assistant.configDir}/automations.yaml 0755 hass hass"
  ];

  # Ensure zigbee2mqtt only starts when the USB device is available
  systemd.services.zigbee2mqtt.unitConfig.ConditionPathExists = "/dev/ttyUSB0";

  services.mosquitto = {
    enable = true;
    listeners = [
      {
        address = "0.0.0.0";
        settings.allow_anonymous = true;
        acl = [ "topic readwrite #" ];
        users.foo = {
          password = "foofoo";
          acl = [ "readwrite #" ];
        };
      }
    ];
  };
  services.zigbee2mqtt = {
    enable = true;
    settings = lib.mkForce {
      homeassistant.enabled = true;
      mqtt.server = "mqtt://localhost:1883";
      serial = {
        port = "/dev/ttyUSB0";
        baudrate = 115200;
        adapter = "ember";
        rtscts = false;
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
      version = 4;
    };
  };

  # Add udev rules for SMLIGHT SLZB-06M to ensure proper device initialization
  services.udev.extraRules = ''
    # SMLIGHT SLZB-06M Zigbee coordinator (CP210x USB-to-UART bridge)
    SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", ATTRS{product}=="SMLIGHT SLZB-06M", SYMLINK+="zigbee", GROUP="dialout", MODE="0666"
    # Ensure device is ready after insertion
    ACTION=="add", SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", RUN+="${pkgs.coreutils}/bin/sleep 2"
  '';

  networking.useHostResolvConf = lib.mkForce false;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      80
      111
      443
      1400 # sonos
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
      21063 # homekit
      21064 # homekit
      21065
      21066
      21067
      51827
    ];
    allowedUDPPorts = [
      111
      1900
      2049
      4000
      4001
      4002
      5353 # homekit
      5683
      20048
      21324
    ];
  };
}
