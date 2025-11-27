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
    flake.modules.nixos.comin
    flake.modules.shared.default
    flake.modules.shared.home-manager
    flake.modules.shared.builders
    flake.modules.nixos.default
    flake.modules.nixos.pipewire
    flake.modules.nixos.zram-swap
    ./disko.nix
  ];

  # Automatic garbage collection and nix store optimization
  nix.gc = {
    automatic = true;
    dates = "monthly";
    options = "--delete-older-than 30d";
  };
  nix.optimise = {
    automatic = true;
    dates = "monthly";
  };

  genki.builders.builders = [
    {
      hostName = "m2";
      system = "aarch64-linux";
      maxJobs = 15;
    }
    {
      hostName = "pbt";
      system = "aarch64-linux";
      maxJobs = 3;
    }
    {
      hostName = "gkr";
      system = "aarch64-darwin";
      maxJobs = 3;
    }
  ];

  # As of kernel version 6.6.72, amdgpu throws a fatal error during init, resulting in a barely-working display
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelParams = [
    # The GPD Pocket 4 uses a tablet LTPS display, that is mounted rotated 90° counter-clockwise
    "fbcon=rotate:1"
    "video=eDP-1:panel_orientation=right_side_up"

    # Real-time audio optimization
    "threadirqs"
    "preempt=voluntary"
    "mitigations=off" # Disable CPU mitigations for lower latency (security tradeoff)
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
      "dialout"
      "video"
      "inputs"
      "uucp"
      "pipewire"
      "audio"
      "rtkit"
    ];
    openssh.authorizedKeys.keyFiles = [ "${flake}/authorized_keys" ];
  };
  nix.settings.trusted-users = [
    "genki"
    "nix-ssh"
  ];

  security.sudo.wheelNeedsPassword = false;

  services.openssh = {
    enable = true;
    # Enable X11 forwarding for clipboard sharing
    extraConfig = ''
      X11Forwarding yes
      X11UseLocalhost yes
    '';
  };
  facter.reportPath = ./facter.json;

  system.stateVersion = "24.11";

  programs.nix-ld.enable = true;

  # We are using zfs: https://github.com/atuinsh/atuin/issues/952#issuecomment-2199964530
  home-manager.users.genki.programs.atuin.daemon.enable = true;

  users.mutableUsers = false;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages =
    with pkgs;
    [
      gnumake
      killall
      niv
      xclip
      xsel
      magic-wormhole-rs
      git
      alacritty
      open-vm-tools
      networkmanagerapplet
      gnome-tweaks
      dconf-editor
      ghostty
      rofi
      rkdeveloptool
      alsa-utils
      systemctl-tui
    ]
    ++ [
      # This is needed for the vmware user tools clipboard to work.
      # You can test if you don't need this by deleting this and seeing
      # if the clipboard sill works.
      shared-mime-info
      xdg-utils
      gtkmm3
    ];

  services.desktopManager.gnome.enable = true;

  services.xserver = {
    enable = true;

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

  # GNOME power settings - disable auto-suspend completely
  services.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.settings-daemon.plugins.power]
    sleep-inactive-ac-type='nothing'
    sleep-inactive-battery-type='nothing'
    sleep-inactive-ac-timeout=0
    sleep-inactive-battery-timeout=0
    power-button-action='nothing'
    idle-dim=false
    idle-brightness=100
    automatic-suspend=false
    automatic-suspend-ac=false
    automatic-suspend-battery=false

    [org.gnome.desktop.session]
    idle-delay=uint32 0

    [org.gnome.desktop.screensaver]
    idle-activation-enabled=false
    lock-enabled=false

    [org.gnome.SessionManager]
    logout-prompt=false
    inhibit-logout-command=\'\'
  '';

  # Disable automatic sleep from all sources
  powerManagement.enable = true;
  powerManagement.powertop.enable = false;
  powerManagement.cpuFreqGovernor = "performance";
  services.tlp.enable = false; # Disable TLP if it's enabled elsewhere

  # Real-time audio optimizations
  security.rtkit.enable = true;

  # Completely disable systemd suspend services
  systemd.services."systemd-suspend" = {
    enable = false;
    serviceConfig.ExecStart = lib.mkForce "${pkgs.coreutils}/bin/true";
  };
  systemd.services."systemd-hibernate" = {
    enable = false;
    serviceConfig.ExecStart = lib.mkForce "${pkgs.coreutils}/bin/true";
  };
  systemd.services."systemd-hybrid-sleep" = {
    enable = false;
    serviceConfig.ExecStart = lib.mkForce "${pkgs.coreutils}/bin/true";
  };

  # Mask suspend targets with high priority
  systemd.targets.sleep.enable = lib.mkForce false;
  systemd.targets.suspend.enable = lib.mkForce false;
  systemd.targets.hibernate.enable = lib.mkForce false;
  systemd.targets.hybrid-sleep.enable = lib.mkForce false;

  # udev rules for Rockchip devices (rkdeveloptool)
  services.udev.extraRules = ''
    # Rockchip devices in maskrom/loader mode
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="2207", MODE="0666"
    # Rockchip devices in recovery mode
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="2207", ATTRS{idProduct}=="*", MODE="0666", GROUP="users"

    # USB device access for katla-frontpanel
    # Genki katla-frontpanel USB device (both product IDs) - NixOS style
    SUBSYSTEM=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="27dd", MODE="0664", GROUP="users", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="20b1", MODE="0664", GROUP="users", TAG+="uaccess"
  '';
}
