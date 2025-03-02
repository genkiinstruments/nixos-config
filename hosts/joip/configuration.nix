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

  users.users.root.openssh.authorizedKeys.keyFiles = [ "${flake}/authorized_keys" ];

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
}
