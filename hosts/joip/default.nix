{ pkgs, user, ... }:
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

  networking.firewall.allowedTCPPorts = [ 8080 ];

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
    config = {
      homeassistant = {
        name = "Home";
        latitude = "!secret latitude";
        longitude = "!secret longitude";
        elevation = 42;
        unit_system = "metric";
        country = "IS";
        temperature_unit = "C";
        internal_url = "http://joip:8123";
        media_dirs.media = "/media";
        allowlist_external_dirs = [ "/tmp" "/media" ];
      };
      default_config = { };
      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [ "::1" ];
      };
      "automation editor" = "!include automations.yaml";
      "scene editor" = "!include scenes.yaml";
      "script editor" = "!include scripts.yaml";
      recorder.purge_keep_days = 60;
      conversation = { intents = { }; };
    };

    customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
      mini-media-player
    ];
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
