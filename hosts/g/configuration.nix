{
  inputs,
  flake,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    inputs.srvos.nixosModules.desktop
    inputs.srvos.nixosModules.mixins-systemd-boot
    inputs.srvos.nixosModules.mixins-terminfo
    inputs.srvos.nixosModules.mixins-trusted-nix-caches
    inputs.disko.nixosModules.disko
    flake.modules.shared.default
    flake.nixosModules.common
    flake.modules.shared.home-manager
    inputs.agenix.nixosModules.default
    inputs.nixos-facter-modules.nixosModules.facter
    ./disko.nix
  ];

  boot = {
    # As of kernel version 6.6.72, amdgpu throws a fatal error during init, resulting in a barely-working display
    kernelPackages = lib.mkIf (lib.versionOlder pkgs.linux.version "6.12") pkgs.linuxPackages_latest;

    kernelParams = [
      # The GPD Pocket 4 uses a tablet LTPS display, that is mounted rotated 90° counter-clockwise
      "fbcon=rotate:1"
      "video=eDP-1:panel_orientation=right_side_up"
    ];
  };

  fonts.fontconfig = {
    subpixel.rgba = "vbgr"; # Pixel order for rotated screen

    # The display has √(2560² + 1600²) px / 8.8in ≃ 343 dpi
    # Per the documentation, antialiasing, hinting, etc. have no visible effect at such high pixel densities anyhow.
    hinting.enable = lib.mkDefault false;
  };

  users.users.genki = {
    isNormalUser = true;
    description = "genki";
    shell = pkgs.fish;
    hashedPassword = "$6$UIOsLjI24UeaovvG$SVVrXdpnepj/w1jhmYNdpPpmcgkcXsMBcAkqrcIL5yCCYDAkc/8kblyzuBLyK6PnJqR1JxZ7XtlWyCJwWhGrw.";
    extraGroups = [
      "networkmanager"
      "wheel"
      "plugdev"
      "dialout"
      "video"
      "inputs"
    ];
    openssh.authorizedKeys.keyFiles = [ "${flake}/authorized_keys" ];
  };

  # More HiDPI settings
  services.xserver.dpi = 343;

  # If the user is in @wheel they are trusted by default.
  nix.settings.trusted-users = [ "@wheel" ];

  security.sudo.wheelNeedsPassword = false;

  # Enable SSH everywhere
  services.openssh.enable = true;

  networking.hostName = "g";

  facter.reportPath = ./facter.json;

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 90;
  };

  system.stateVersion = "24.11";

  programs.nix-ld.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = false;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages =
    with pkgs;
    [
      cachix
      gnumake
      killall
      niv
      xclip
      magic-wormhole-rs
      git
      alacritty
      open-vm-tools
      networkmanagerapplet
      gnome-tweaks
      dconf-editor
      ghostty
      rofi

      # For hypervisors that support auto-resizing, this script forces it.
      # I've noticed not everyone listens to the udev events so this is a hack.
      (writeShellScriptBin "xrandr-auto" ''
        xrandr --output Virtual-1 --auto
      '')
    ]
    ++ [
      # This is needed for the vmware user tools clipboard to work.
      # You can test if you don't need this by deleting this and seeing
      # if the clipboard sill works.
      shared-mime-info
      xdg-utils
      gtkmm3
    ];

  services.displayManager.defaultSession = "none+i3";

  services.xserver = {
    enable = true;
    # displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;

    desktopManager = {
      xterm.enable = false;
      wallpaper.mode = "fill";
    };

    displayManager = {
      lightdm.enable = true;

      # AARCH64: For now, on Apple Silicon, we must manually set the
      # display resolution. This is a known issue with VMware Fusion.
      sessionCommands = ''
        ${pkgs.xorg.xset}/bin/xset r rate 200 40
      '';
    };

    windowManager.i3.enable = true;
  };

  # GNOME packages
  environment.gnome.excludePackages = with pkgs; [
    epiphany # web browser
    totem # video player
    geary # email client
    evince # document viewer
    # Add other GNOME packages you want to exclude
  ];

  # We need an XDG portal for various applications to work properly,
  # such as Flatpak applications.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  services.udev.packages = [
    pkgs.yubikey-personalization
    pkgs.libfido2
  ];

}
