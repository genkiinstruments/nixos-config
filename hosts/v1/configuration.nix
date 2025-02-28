{
  pkgs,
  inputs,
  lib,
  config,
  flake,
  ...
}:
{
  imports = [
    ./disko-config.nix
    inputs.disko.nixosModules.disko
    inputs.srvos.nixosModules.desktop
    inputs.srvos.nixosModules.mixins-terminfo
    inputs.srvos.nixosModules.mixins-nix-experimental
    inputs.srvos.nixosModules.mixins-trusted-nix-caches
    inputs.agenix.nixosModules.default
    flake.modules.shared.default
    flake.modules.shared.home-manager
    flake.nixosModules.common
  ];

  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "gdrn";
        sshUser = "nix-ssh";
        protocol = "ssh-ng";
        systems = [
          "aarch64-linux"
          "x86_64-linux"
        ];
        maxJobs = 128;
        sshKey = config.age.secrets.nix-ssh-v1-gdrn.path;
        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUl1UHF1RTUwNDVZcUFwZ2swdzBrU0d5ZHBhbDVaTVNmTWlablR6MHVOWDMgcm9vdEBnZHJuCg==";
        supportedFeatures = [
          "nixos-test"
          "benchmark"
          "big-parallel"
          "kvm"
        ];
      }
    ];
  };
  age.secrets.nix-ssh-v1-gdrn.file = "${inputs.secrets}/nix-ssh-v1-gdrn.age";
  age.secrets.v1-top-secret.file = "${inputs.secrets}/v1-top-secret.age";

  nix.sshServe = {
    protocol = "ssh-ng";
    enable = true;
    write = true;
    # For Nix remote builds, the SSH authentication needs to be non-interactive and not dependent on ssh-agent, since the Nix daemon needs to be able to authenticate automatically.
    keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF0V/P7rcJdL7gumCvQPgbsZoMgfF8FcOAE++LsyZPCr olafur@M3.local"
    ];
  };
  nix.settings.trusted-users = [
    "nix-ssh"
    "@wheel"
  ];
  users.users.nix-ssh.openssh.authorizedKeys.keyFiles = [ ../../authorized_keys ];

  # Be careful updating this.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Use the systemd-boot EFI boot loader. arm uses EFI, so we need systemd-boot
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

  # Enable tailscale. We manually authenticate when we want with "sudo tailscale up".
  services.tailscale.enable = true;
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

    dpi = 220;

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

  # Disable the firewall since we're in a VM and we want to make it
  # easy to visit stuff in here. We only use NAT networking anyways.
  networking.firewall.enable = false;

  networking.hostName = "v1"; # Define your hostname.

  services.udev.packages = [
    pkgs.yubikey-personalization
    pkgs.libfido2
  ];

  programs.ssh = {
    startAgent = true;
    # Add these settings
    extraConfig = ''
      StreamLocalBindUnlink yes
    '';
  };

  # And maybe add these SSH daemon settings
  services.openssh = {
    enable = true;
    settings = {
      AllowAgentForwarding = true;
      StreamLocalBindUnlink = true;
    };
  };

  # Set your time zone.
  time.timeZone = "Atlantic/Reykjavik";

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

  # For now, we need this since hardware acceleration does not work.
  environment.variables.LIBGL_ALWAYS_SOFTWARE = "1";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
