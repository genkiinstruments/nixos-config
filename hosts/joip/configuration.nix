{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    inputs.srvos.nixosModules.server
    inputs.srvos.nixosModules.mixins-systemd-boot
    inputs.srvos.nixosModules.mixins-terminfo
    inputs.srvos.nixosModules.mixins-nix-experimental
    inputs.srvos.nixosModules.mixins-trusted-nix-caches
    inputs.nixos-hardware.nixosModules.intel-nuc-8i7beh
    inputs.home-manager.nixosModules.home-manager
    inputs.disko.nixosModules.disko
    inputs.agenix.nixosModules.default
    inputs.self.modules.shared.default
    inputs.self.nixosModules.servarr
    inputs.self.nixosModules.homepage
    inputs.self.nixosModules.common
    ./disk-config.nix
    ./hardware-configuration.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "23.05"; # Did you read the comment?

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  age = {
    secrets = {
      "my-secret" = {
        symlink = true;
        path = "/home/olafur/my-secret";
        file = "${inputs.secrets}/my-secret.age";
        mode = "644";
        owner = "olafur";
        group = "users";
      };
      dashboard-env = {
        symlink = true;
        file = "${inputs.secrets}/homepage-dashboard-env.age";
        owner = "olafur";
        group = "users";
        mode = "644";
      };
      atuin-key = {
        symlink = true;
        path = "/home/olafur/.local/share/atuin/key";
        file = "${inputs.secrets}/atuin-key.age";
        mode = "644";
        owner = "olafur";
        group = "users";
      };
    };
  };
  users.users.olafur = {
    isNormalUser = true;
    shell = "/run/current-system/sw/bin/fish";
    openssh.authorizedKeys.keyFiles = [ ../../authorized_keys ];
    extraGroups = [ "wheel" ];
  };
  users.users.root.openssh.authorizedKeys.keyFiles = [ ../../authorized_keys ];
  nix.settings.trusted-users = [
    "root"
    "@wheel"
    "olafur"
  ];

  networking.hostName = "joip";

  systemd.services.NetworkManager-wait-online.enable = false; # Workaround https://github.com/NixOS/nixpkgs/issues/180175

  home-manager.users.olafur.imports = [ inputs.self.homeModules.default ];

  programs.fish.enable = true; # Otherwise our shell won't be installed correctly
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
