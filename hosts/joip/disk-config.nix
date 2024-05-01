# https://github.com/nix-community/disko/blob/master/example/hybrid.nix
{
  disko.devices = {
    disk = {
      main = {
        device = "/dev/disk/by-id/nvme-eui.0000000001000000e4d25c6bf01d5101";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02"; # for grub MBR
            };
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
