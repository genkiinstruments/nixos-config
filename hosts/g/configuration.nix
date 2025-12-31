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
    inputs.stylix.nixosModules.stylix
    inputs.agenix.nixosModules.default
    inputs.nixos-facter-modules.nixosModules.facter
    flake.modules.shared.default
    flake.modules.shared.home-manager
    flake.modules.shared.builders
    flake.modules.nixos.default
    flake.modules.nixos.comin
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
    # AMD GPU stability fixes for external displays
    "amdgpu.dcdebugmask=0x10" # Disable PSR
    "amdgpu.dcfeaturemask=0x8" # Disable PSR in DCN
    "amdgpu.abmlevel=0" # Disable ABM (adaptive backlight)
    "amdgpu.ppfeaturemask=0xfffd3fff" # Disable GFXOFF power feature
    "amdgpu.runpm=0" # Disable runtime power management
    "amdgpu.bapm=0" # Disable bidirectional APM
    "amdgpu.sg_display=0" # Disable scatter-gather display
    "amdgpu.audio=0" # Disable HDMI/DP audio (can cause link issues)
  ];

  # Stylix system-wide theming
  stylix = {
    enable = true;
    autoEnable = true;
    # Catppuccin Mocha - inlined to avoid IFD
    base16Scheme = {
      base00 = "#1e1e2e"; # base
      base01 = "#181825"; # mantle
      base02 = "#313244"; # surface0
      base03 = "#45475a"; # surface1
      base04 = "#585b70"; # surface2
      base05 = "#cdd6f4"; # text
      base06 = "#f5e0dc"; # rosewater
      base07 = "#b4befe"; # lavender
      base08 = "#f38ba8"; # red
      base09 = "#fab387"; # peach
      base0A = "#f9e2af"; # yellow
      base0B = "#a6e3a1"; # green
      base0C = "#94e2d5"; # teal
      base0D = "#89b4fa"; # blue
      base0E = "#cba6f7"; # mauve
      base0F = "#f2cdcd"; # flamingo
    };
    polarity = "dark";
    # Pure black wallpaper
    image = pkgs.runCommand "black.png" { nativeBuildInputs = [ pkgs.imagemagick ]; } ''
      magick -size 1x1 xc:'#000000' $out
    '';
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.noto-fonts;
        name = "Noto Sans";
      };
      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };
      sizes = {
        terminal = 14;
        applications = 12;
      };
    };
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

  programs.nix-ld.enable = true;

  # We are using zfs: https://github.com/atuinsh/atuin/issues/952#issuecomment-2199964530
  home-manager.users.genki.programs.atuin.daemon.enable = true;

  environment.systemPackages = with pkgs; [
    firefox
    spotify
    gnumake
    killall
    niv
    magic-wormhole-rs
    git
    ghostty
    signal-desktop
    rkdeveloptool
    alsa-utils
    systemctl-tui
    xwayland-satellite
    walker # app launcher (raycast-like)
    cliphist # clipboard history for walker
    mako # notifications
    wl-clipboard # clipboard
    swaylock
    swaybg
    kanshi # display configuration
    libnotify # for notify-send
    brightnessctl # brightness control
    playerctl # media control
    yubikey-manager # Yubikey management
    libfido2 # FIDO2 support for SSH
    wev # Wayland event viewer for debugging
  ];

  # Networking
  networking.networkmanager.enable = true;

  # SSH with FIDO2/Yubikey support
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  # Yubikey/FIDO2 support for SSH authentication from this machine
  hardware.gpgSmartcards.enable = true;
  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];

  # Electron/Chromium apps use Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Prefer dark mode system-wide (catppuccin theme set via home-manager)
  programs.dconf.enable = true;

  # Default font size 14
  fonts.fontconfig.defaultFonts = {
    monospace = [ "JetBrainsMono Nerd Font Mono" ];
    sansSerif = [ "Noto Sans" ];
    serif = [ "Noto Serif" ];
  };
  fonts.fontconfig.hinting.style = "slight";

  # Niri - scrollable tiling Wayland compositor
  programs.niri.enable = true;

  # XDG portal for screen sharing, file dialogs
  xdg.portal.wlr.enable = true;

  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.gnome.gcr-ssh-agent.enable = false; # Doesn't support FIDO2
  security.pam.services.swaylock = { };

  # Use OpenSSH's native agent which supports FIDO2
  programs.ssh.startAgent = true;

  # Logitech wireless support
  hardware.logitech.wireless.enable = true;

  # Hyperkey via keyd (Caps = Hyper when held, Escape when tapped)
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings = {
        main = {
          capslock = "overload(hyper, esc)";
        };
        # Hyper = Ctrl+Alt+Super (no Shift, so Shift can be used for move bindings)
        "hyper:C-A-M" = { };
      };
    };
  };

  # greetd for login
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri-session";
        user = "greeter";
      };
    };
  };

  # Power management
  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "performance";

  security.rtkit.enable = true;

  # Disable suspend
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
    SUBSYSTEM=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="27dd", MODE="0664", GROUP="users", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="20b1", MODE="0664", GROUP="users", TAG+="uaccess"
  '';
}
