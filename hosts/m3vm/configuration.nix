{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    ./disko-config.nix
    ./vmware-guest.nix
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    inputs.srvos.nixosModules.desktop
    inputs.srvos.nixosModules.mixins-terminfo
    inputs.srvos.nixosModules.mixins-nix-experimental
    inputs.srvos.nixosModules.mixins-trusted-nix-caches
    inputs.self.modules.shared.default
    inputs.self.nixosModules.common
  ];

  # Be careful updating this.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Use the systemd-boot EFI boot loader.
  # arm uses EFI, so we need systemd-boot
  boot.loader.systemd-boot.enable = true;

  # since it's a vm, we can do this on every update safely
  boot.loader.efi.canTouchEfiVariables = true;

  # VMware, Parallels both only support this being 0 otherwise you see
  # "error switching console mode" on boot.
  boot.loader.systemd-boot.consoleMode = "0";

  boot.initrd.availableKernelModules = [
    "uhci_hcd"
    "ahci"
    "xhci_pci"
    "nvme"
    "usbhid"
    "sr_mod"
  ];
  boot.binfmt.emulatedSystems = [ "x86_64-linux" ];

  networking.interfaces.ens160.useDHCP = true;
  disabledModules = [ "virtualisation/vmware-guest.nix" ];

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;

  # Don't require password for sudo
  security.sudo.wheelNeedsPassword = false;

  virtualisation.vmware.guest.enable = true;
  virtualisation.lxd.enable = true;
  virtualisation.docker.enable = true;

  # Select internationalisation properties.
  i18n = {
    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
        fcitx5-chinese-addons
      ];
    };
  };

  # Enable tailscale. We manually authenticate when we want with
  # "sudo tailscale up". If you don't use tailscale, you should comment
  # out or delete all of this.
  services.tailscale.enable = true;

  # Configure home-manager for Hyprland
  home-manager.users.genki =
    { pkgs, ... }:
    {
      imports = [ inputs.self.homeModules.default ];
      programs.ssh = {
        matchBlocks = {
          "github.com" = {
            user = "git";
            identityFile = "~/.ssh/id_ed25519_sk";
            identitiesOnly = true;
          };
        };
        controlMaster = "auto";
        controlPath = "/tmp/ssh-%u-%r@%h:%p";
        controlPersist = "1800";
        forwardAgent = true;
        addKeysToAgent = "yes";
        serverAliveInterval = 900;
        extraConfig = "SetEnv TERM=xterm-256color";
      };
      wayland.windowManager.hyprland = {
        enable = true;
        settings = {
          "$mod" = "SUPER";

          bind = [
            "$mod, Return, exec, ghostty"
            "$mod, Q, killactive"
            "$mod, M, exit"
            "$mod, E, exec, dolphin"
            "$mod, V, togglefloating"
            "$mod, R, exec, wofi --show drun"
            "$mod, P, pseudo"
            "$mod, J, togglesplit"
            "$mod, F, fullscreen"

            # Move focus
            "$mod, left, movefocus, l"
            "$mod, right, movefocus, r"
            "$mod, up, movefocus, u"
            "$mod, down, movefocus, d"

            # Workspaces
            "$mod, 1, workspace, 1"
            "$mod, 2, workspace, 2"
            "$mod, 3, workspace, 3"
            "$mod, 4, workspace, 4"
            "$mod, 5, workspace, 5"
            "$mod, 6, workspace, 6"
            "$mod, 7, workspace, 7"
            "$mod, 8, workspace, 8"
            "$mod, 9, workspace, 9"

            # Move windows to workspaces
            "$mod SHIFT, 1, movetoworkspace, 1"
            "$mod SHIFT, 2, movetoworkspace, 2"
            "$mod SHIFT, 3, movetoworkspace, 3"
            "$mod SHIFT, 4, movetoworkspace, 4"
            "$mod SHIFT, 5, movetoworkspace, 5"
            "$mod SHIFT, 6, movetoworkspace, 6"
            "$mod SHIFT, 7, movetoworkspace, 7"
            "$mod SHIFT, 8, movetoworkspace, 8"
            "$mod SHIFT, 9, movetoworkspace, 9"
          ];

          exec-once = [
            "waybar"
            "mako"
            "dunst"
            "vmware-user-suid-wrapper"
          ];

          monitor = [
            "Virtual-1,1920x1080@60,0x0,1"
          ];

          general = {
            gaps_in = 5;
            gaps_out = 20;
            border_size = 2;
            "col.active_border" = "rgba(33ccffee)";
            "col.inactive_border" = "rgba(595959aa)";
          };
        };
      };

      # Dunst configuration
      services.dunst = {
        enable = true;
        settings = {
          global = {
            font = "JetBrains Mono 10";
            frame_width = 2;
            frame_color = "#8AADF4";
          };
        };
      };

      # Mako configuration
      services.mako = {
        enable = true;
        defaultTimeout = 5000;
        font = "JetBrains Mono 10";
        backgroundColor = "#1E1E2E";
        textColor = "#CDD6F4";
        borderColor = "#89B4FA";
        borderRadius = 8;
        borderSize = 2;
        margin = "10";
        padding = "15";
      };

      # Waybar configuration
      programs.waybar = {
        enable = true;
        settings = [
          {
            height = 30;
            modules-left = [
              "hyprland/workspaces"
              "hyprland/mode"
            ];
            modules-center = [ "hyprland/window" ];
            modules-right = [
              "pulseaudio"
              "network"
              "cpu"
              "memory"
              "clock"
              "tray"
            ];
          }
        ];
      };
    };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = false;

  # Manage fonts. We pull these from a secret directory since most of these
  # fonts require a purchase.
  fonts = {
    fontDir.enable = true;

    packages = [
      pkgs.fira-code
      pkgs.jetbrains-mono
    ];
  };

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
      ghostty
      open-vm-tools
      waybar # Status bar
      wofi # Application launcher
      dunst # Notification daemon
      mako # Alternative notification daemon
      wl-clipboard # Clipboard manager
      grim # Screenshot utility
      slurp # Screen area selection
      swaylock # Screen locker
      swayidle # Idle management daemon
      wlsunset # Night light
      light # Brightness control
      pamixer # PulseAudio control
      pavucontrol # PulseAudio GUI
      networkmanagerapplet

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
  environment.sessionVariables = {
    LIBGL_ALWAYS_SOFTWARE = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Disable unnecessary services that might cause issues
  services.power-profiles-daemon.enable = false;
  services.geoclue2.enable = false;
  services.hardware.bolt.enable = false;
  services.fprintd.enable = false;

  # Our default non-specialised desktop environment.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "genki";
  services.dbus.enable = true;
  services.gvfs.enable = true;
  # XDG Portal for screen sharing
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # Replace with greetd auto-login configuration
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter";
      };
      # Add auto-login configuration
      initial_session = {
        command = "Hyprland";
        user = "genki";
      };
    };
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable flatpak. I don't use any flatpak apps but I do sometimes
  # test them so I keep this enabled.
  services.flatpak.enable = true;

  # Enable snap. I don't really use snap but I do sometimes test them
  # and release snaps so we keep this enabled.
  # services.snap.enable = true;

  # Disable the firewall since we're in a VM and we want to make it
  # easy to visit stuff in here. We only use NAT networking anyways.
  networking.firewall.enable = false;

  networking.hostName = "m3vm"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  services.udev.packages = [
    pkgs.yubikey-personalization
    pkgs.libfido2
  ];

  programs.ssh = {
    startAgent = true;
    extraConfig = ''
      Host *
        ForwardAgent yes
        SecurityKeyProvider /dev/hidraw1  # This might be optional depending on your setup
    '';
  };

  # Ensure the udev rules are loaded
  services.udev.enable = true;

  # Enable networking
  networking.networkmanager.enable = true;

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
    openssh.authorizedKeys.keyFiles = [ ../../authorized_keys ];
  };
  users.users.root.openssh.authorizedKeys.keyFiles = [ ../../authorized_keys ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

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
  system.stateVersion = "24.11"; # Did you read the comment?
}
