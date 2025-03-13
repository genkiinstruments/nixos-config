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
    flake.nixosModules.common
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
}
