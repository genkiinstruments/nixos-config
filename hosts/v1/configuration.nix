{
  pkgs,
  inputs,
  lib,
  flake,
  ...
}:
{
  imports = [
    ./disko-config.nix
    inputs.disko.nixosModules.disko
    inputs.srvos.nixosModules.desktop
    inputs.srvos.nixosModules.mixins-terminfo
    inputs.srvos.nixosModules.mixins-systemd-boot
    inputs.agenix.nixosModules.default
    flake.modules.shared.default
    flake.modules.shared.home-manager
    flake.modules.nixos.default
    flake.modules.nixos.zram-swap
    flake.modules.nixos.olafur
    flake.modules.nixos.ssh-serve
    flake.modules.nixos.pipewire
    flake.modules.nixos.comin
  ];

  # Be careful updating this.
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  boot.kernelPackages = pkgs.linuxPackages_latest;
  system.stateVersion = "24.11"; # Did you read the comment?

  # VMware, Parallels both only support this being 0 otherwise you see "error switching console mode" on boot.
  boot.loader.systemd-boot.consoleMode = "0";

  boot.initrd.availableKernelModules = [
    "uhci_hcd"
    "ahci"
    "xhci_pci"
    "nvme"
    "usbhid"
    "sr_mod"
    "ata_piix"
    "mptspi"
    "vmxnet3"
  ];

  # VMware specific optimizations
  boot.initrd.kernelModules = [
    "vmw_vmci"
    "vmwgfx"
  ];
  boot.kernelParams = [
    "vmware_balloon.dynamic_entitlement=1"
    "vmware_balloon.first_time_delay=0"
  ];
  boot.binfmt.emulatedSystems = [ "x86_64-linux" ];

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;

  # VM performance tuning
  services.fstrim.enable = true; # Enables periodic TRIM for better disk performance
  services.fstrim.interval = "daily";

  # Set vm.swappiness for better VM memory management
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
  };

  # Enhanced VMware guest support
  virtualisation.vmware.guest = {
    enable = true;
    headless = false; # Set to true if this is a headless server
  };
  virtualisation.docker.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages =
    with pkgs;
    [
      gnumake
      killall
      niv
      xclip
      magic-wormhole-rs
      git
      open-vm-tools
      networkmanagerapplet
      gnome-tweaks
      dconf-editor
      ghostty
      rofi
      neofetch

      # Better clipboard support for VMware
      wl-clipboard
      xsel

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
  services.desktopManager.gnome.enable = true;

  # Disable GNOME's SSH agent to avoid conflict with programs.ssh.startAgent
  services.gnome.gcr-ssh-agent.enable = false;

  services.xserver = {
    enable = true;

    dpi = 220;

    desktopManager = {
      xterm.enable = false;
      wallpaper.mode = "fill";
    };

    displayManager = {
      lightdm.enable = true;

      sessionCommands = ''
        # Set keyboard repeat rate for better responsiveness
        ${pkgs.xorg.xset}/bin/xset r rate 200 40
      '';
    };

    windowManager.i3.enable = true;
  };

  # Disable the firewall since we're in a VM and we want to make it easy to visit stuff in here. We only use NAT networking anyways.
  networking.firewall.enable = false;

  programs.ssh.startAgent = true;
  programs.firefox.enable = true;
  programs.nix-ld.enable = true;

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

  # For now, we need this since hardware acceleration does not work.
  environment.variables.LIBGL_ALWAYS_SOFTWARE = "1";
}
