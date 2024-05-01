{ pkgs, user, ... }:
let
  homekit-tcp-port = 21063; # Freely choosable
  homekit-udp-port = 5353; # Hardcoded by apple, I think
  nginx-port = 80;
  ha-port = 8123;
in
{
  imports =
    [
      ./disk-config.nix
      ./hardware-configuration.nix
      ../../modules/shared/home-manager.nix
      ../../modules/shared
      ../../modules/shared/cachix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Emulate arm64 binaries
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "joip"; # Define your hostname.

  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Atlantic/Reykjavik";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "is_IS.UTF-8";
    LC_IDENTIFICATION = "is_IS.UTF-8";
    LC_MEASUREMENT = "is_IS.UTF-8";
    LC_MONETARY = "is_IS.UTF-8";
    LC_NAME = "is_IS.UTF-8";
    LC_NUMERIC = "is_IS.UTF-8";
    LC_PAPER = "is_IS.UTF-8";
    LC_TELEPHONE = "is_IS.UTF-8";
    LC_TIME = "is_IS.UTF-8";
  };

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user} = {
    isNormalUser = true;
    description = "${user}";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    hashedPassword = "$y$j9T$EIhzkT6pSVKuf79oPtE670$0PIzTEEUhafRQPEfJTdgX99VxefWrT.5I7BQJqDpAT/";
  };

  nix.settings.trusted-users = [ "root" "@wheel" "${user}" ];

  services.openssh.enable = true;

  services.tailscale.enable = true;

  services.home-assistant = {
    enable = true;

    extraComponents = [
      "apple_tv"
      "default_config"
      "denonavr"
      "esphome"
      "homekit"
      "homekit_controller"
      "ipp"
      "lovelace"
      "media_player"
      "mjpeg"
      "mqtt"
      "prusalink"
      "spotify"
      "vacuum"
      "weather"
      "wled"
      "xiaomi_miio"
    ];
    extraPackages = python3Packages: with python3Packages; [ pip gtts dateutil aiohomekit pyatv getmac async-upnp-client ];
    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = { };
      homekit = {
        port = homekit-tcp-port;
        filter = {
          exclude_entity_globs = [ "automation.*" ];
        };
      };
    };
  };
  services.nginx = {
    enable = true;
    defaultListen = [
      { addr = "0.0.0.0"; port = nginx-port; }
    ];
    # Adds headers Host, X-Real-IP, X-Forwarded-For (and others)
    recommendedProxySettings = true;
    # TODO The guide has a separate location set up for /api/websocket, but this appears unnecessary?
    virtualHosts = {
      "joip.lan" = {
        locations."/" = {
          proxyPass = "http://localhost:${builtins.toString ha-port}";
          extraConfig = ''
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
          '';
        };
      };
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ homekit-tcp-port nginx-port ha-port ];
    allowedUDPPorts = [ homekit-udp-port ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
