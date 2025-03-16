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
    inputs.agenix.nixosModules.default
    inputs.nixos-facter-modules.nixosModules.facter
    flake.modules.shared.default
    flake.modules.shared.home-manager
    flake.nixosModules.common
    ./disko.nix
  ];

  # As of kernel version 6.6.72, amdgpu throws a fatal error during init, resulting in a barely-working display
  boot.kernelPackages = lib.mkIf (lib.versionOlder pkgs.linux.version "6.12") pkgs.linuxPackages_latest;

  boot.kernelParams = [
    # The GPD Pocket 4 uses a tablet LTPS display, that is mounted rotated 90° counter-clockwise
    "fbcon=rotate:1"
    "video=eDP-1:panel_orientation=right_side_up"
  ];

  fonts.fontconfig = {
    subpixel.rgba = "vbgr"; # Pixel order for rotated screen

    # Per the documentation, antialiasing, hinting, etc. have no visible effect at such high pixel densities anyhow.
    hinting.enable = lib.mkDefault false;
  };
  #
  # The display has √(2560² + 1600²) px / 8.8in ≃ 343 dpi
  services.xserver.dpi = 343;

  users.users.genki = {
    isNormalUser = true;
    description = "genki";
    shell = pkgs.fish;
    hashedPassword = "$6$UIOsLjI24UeaovvG$SVVrXdpnepj/w1jhmYNdpPpmcgkcXsMBcAkqrcIL5yCCYDAkc/8kblyzuBLyK6PnJqR1JxZ7XtlWyCJwWhGrw.";
    extraGroups = [
      "wheel"
      "networkmanager"
      "plugdev"
      "dialout"
      "video"
      "inputs"
    ];
    openssh.authorizedKeys.keyFiles = [ "${flake}/authorized_keys" ];
  };

  security.sudo.wheelNeedsPassword = false;

  services.openssh.enable = true;
  networking.hostName = "g";

  facter.reportPath = ./facter.json;

  services.tailscale.enable = true;

  # Reduce the timeout from the default 90 seconds to something shorter
  systemd.services.tailscale.serviceConfig.TimeoutStopSec = 5;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 90;
  };

  system.stateVersion = "24.11";

  programs.nix-ld.enable = true;

  # We are using zsh: https://github.com/atuinsh/atuin/issues/952#issuecomment-2199964530
  home-manager.users.genki.programs.atuin.settings.daemon.enabled = false;

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
    ]
    ++ [
      # This is needed for the vmware user tools clipboard to work.
      # You can test if you don't need this by deleting this and seeing
      # if the clipboard sill works.
      shared-mime-info
      xdg-utils
      gtkmm3
    ];

  services.xserver = {
    enable = true;
    # displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;

    desktopManager.xterm.enable = false;
    desktopManager.wallpaper.mode = "fill";
    # displayManager.lightdm.enable = true;
    # windowManager.i3.enable = true;
  };

  # GNOME packages
  environment.gnome.excludePackages = with pkgs; [
    epiphany # web browser
    totem # video player
    geary # email client
    evince # document viewer
    # Add other GNOME packages you want to exclude
  ];

  services.udev.packages = [
    pkgs.yubikey-personalization
    pkgs.libfido2
  ];

}
