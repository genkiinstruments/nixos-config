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
    flake.modules.nixos.katla-udev
    ./disko.nix
  ];

  system.stateVersion = "24.11";
  facter.reportPath = ./facter.json;

  genki.builders = [
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

  boot.kernelParams = [
    # GPD Pocket 4 rotated display
    "fbcon=rotate:1"
    "video=eDP-1:panel_orientation=right_side_up"
  ];

  fonts.fontconfig = {
    subpixel.rgba = "vbgr";
    hinting.enable = lib.mkDefault false;
  };

  users.mutableUsers = false;
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
  nix.settings.trusted-users = [ "genki" ];

  security.sudo.wheelNeedsPassword = false;

  services.openssh = {
    enable = true;
    extraConfig = ''
      X11Forwarding yes
      X11UseLocalhost yes
    '';
  };

  programs.nix-ld.enable = true;

  # We are using zfs: https://github.com/atuinsh/atuin/issues/952#issuecomment-2199964530
  home-manager.users.genki.programs.atuin.daemon.enable = true;

  environment.systemPackages = with pkgs; [
    gnumake
    killall
    niv
    xclip
    xsel
    magic-wormhole-rs
    git
    alacritty
    networkmanagerapplet
    gnome-tweaks
    dconf-editor
    ghostty
    rofi
    rkdeveloptool
    alsa-utils
    systemctl-tui
    shared-mime-info
    xdg-utils
    gtkmm3
  ];

  services.desktopManager.gnome.enable = true;

  services.xserver = {
    enable = true;
    desktopManager.wallpaper.mode = "fill";
    dpi = 343; # The display has √(2560² + 1600²) px / 8.8in ≃ 343 dpi
  };

  environment.gnome.excludePackages = with pkgs; [
    epiphany
    totem
    geary
    evince
  ];

  services.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.settings-daemon.plugins.power]
    sleep-inactive-ac-type='nothing'
    sleep-inactive-battery-type='nothing'
    sleep-inactive-ac-timeout=0
    sleep-inactive-battery-timeout=0
    power-button-action='nothing'
    idle-dim=false

    [org.gnome.desktop.session]
    idle-delay=uint32 0

    [org.gnome.desktop.screensaver]
    idle-activation-enabled=false
    lock-enabled=false
  '';

  powerManagement.cpuFreqGovernor = "performance";

  security.rtkit.enable = true;

  systemd.targets.sleep.enable = lib.mkForce false;
  systemd.targets.suspend.enable = lib.mkForce false;
  systemd.targets.hibernate.enable = lib.mkForce false;
  systemd.targets.hybrid-sleep.enable = lib.mkForce false;
}
