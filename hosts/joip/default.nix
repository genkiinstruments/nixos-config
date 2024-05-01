{ pkgs, lib, user, ... }:
{
  imports =
    [
      ./disk-config.nix
      ./hardware-configuration.nix
      ../../modules/shared/home-manager.nix
      ../../modules/shared
      ../../modules/shared/cachix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Emulate arm64 binaries
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "joip"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # TODO: Do we need all these interfaces to WoL?
  networking.interfaces.enp11s0.wakeOnLan.enable = true; # 74:56:3c:3d:d8:82 1Gbps
  networking.interfaces.enp10s0.wakeOnLan.enable = true; # 98:b7:85:1e:f6:4f 10Gbps

  # Set your time zone.
  time.timeZone = "Atlantic/Reykjavik";

  # Select internationalisation properties.
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

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Place GitHub Access token under ~/.config/nix/nix.conf: access-tokens = github.com=***censored***
  nix.settings.experimental-features = lib.mkDefault "nix-command flakes";

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  networking.firewall.allowedTCPPorts = [ 8080 ];

  # Enable tailscale. We manually authenticate when we want with "sudo tailscale up". 
  services.tailscale.enable = true;

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
