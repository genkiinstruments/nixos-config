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
    flake.modules.nixos.comin
    flake.modules.nixos.zram-swap
    flake.modules.nixos.olafur
    flake.modules.nixos.ssh-serve
    flake.modules.nixos.pipewire
  ];

  system.stateVersion = "24.11";

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # VMware, Parallels both only support this being 0 otherwise you see "error switching console mode" on boot.
  boot.loader.systemd-boot.consoleMode = "0";

  boot.initrd.kernelModules = [
    "vmw_vmci"
    "vmwgfx"
  ];
  boot.kernelParams = [
    "vmware_balloon.dynamic_entitlement=1"
    "vmware_balloon.first_time_delay=0"
  ];
  boot.binfmt.emulatedSystems = [ "x86_64-linux" ];

  networking.useDHCP = false;

  services.fstrim.enable = true;

  virtualisation.vmware.guest.enable = true;
  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
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
    wl-clipboard
    xsel
    shared-mime-info
    xdg-utils
    gtkmm3

    (writeShellScriptBin "xrandr-auto" ''
      xrandr --output Virtual-1 --auto
    '')
  ];

  services.displayManager.defaultSession = "none+i3";
  services.desktopManager.gnome.enable = true;
  services.gnome.gcr-ssh-agent.enable = false;

  services.xserver = {
    enable = true;
    dpi = 220;

    desktopManager.wallpaper.mode = "fill";

    displayManager = {
      lightdm.enable = true;
      sessionCommands = ''
        ${pkgs.xorg.xset}/bin/xset r rate 200 40
      '';
    };

    windowManager.i3.enable = true;
  };

  networking.firewall.enable = false;

  programs.ssh.startAgent = true;
  programs.firefox.enable = true;
  programs.nix-ld.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      AllowAgentForwarding = true;
      StreamLocalBindUnlink = true;
    };
  };

  time.timeZone = "Atlantic/Reykjavik";

  environment.variables.LIBGL_ALWAYS_SOFTWARE = "1";
}
