{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [ ./disko-config.nix ];
  disko.devices.disk.main.device = "/dev/disk/by-id/nvme-eui.002538b931a6cbb0";

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usb_storage"
    "usbhid"
    "sd_mod"
    "sr_mod"
  ];
  boot.kernelModules = [ "kvm-amd" ];

  nix.gc.automatic = true;
  nix.gc.dates = "*:45";
  nix.gc.options = ''--max-freed "$((128 * 1024**3 - 1024 * $(df -P -k /nix/store | tail -n 1 | ${pkgs.gawk}/bin/awk '{ print $4 }')))"'';

  networking.networkmanager.enable = true;
  networking.useDHCP = lib.mkDefault true;

  virtualisation.docker.enable = true;
  virtualisation.multipass.enable = true;

  # Enable tailscale. We manually authenticate when we want with "sudo tailscale up". 
  services.tailscale.enable = true;

  system.stateVersion = "23.05"; # Did you read the comment?
  roles.github-actions-runner = {
    url = "https://github.com/genkiinstruments";
    count = 4;
    name = "gdrn-github-runner";
    githubApp = {
      id = "1003596";
      login = "genkiinstruments";
      privateKeyFile = config.age.secrets.gdrn-github-runner-key.path;
    };
    cachix.cacheName = "genki";
    cachix.tokenFile = config.age.secrets.gdrn-github-runner-cachixToken.path;
  };
}
