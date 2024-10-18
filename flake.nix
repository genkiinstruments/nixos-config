{
  description = "Nix runs my 🌍🌎🌏";
  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    srvos.url = "github:nix-community/srvos";
    # srvos.follows = "nixpkgs";
    nixpkgs.follows = "srvos/nixpkgs"; # use the version of nixpkgs that has been tested with SrvOS
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-darwin.follows = "nix-darwin";
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-aerospace = {
      url = "github:nikitabobko/homebrew-tap";
      flake = false;
    };
    homebrew-zkondor = {
      url = "github:zkondor/homebrew-dist";
      flake = false;
    };
    homebrew-ssh-askpass = {
      url = "github:theseal/homebrew-ssh-askpass";
      flake = false;
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";
    agenix.url = "github:ryantm/agenix";
    secrets = {
      url = "git+ssh://git@github.com/multivac61/nix-secrets.git";
      flake = false;
    };
  };
  outputs =
    {
      self,
      srvos,
      nix-darwin,
      nix-homebrew,
      home-manager,
      nixpkgs,
      nixos-hardware,
      nix-index-database,
      disko,
      catppuccin,
      secrets,
      agenix,
      ...
    }@inputs:
    let
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ] f;
      devShell =
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default =
            with pkgs;
            mkShell {
              buildInputs = [
                bashInteractive
                git
                nixos-anywhere
                age
                age-plugin-yubikey
                age-plugin-fido2-hmac
              ] ++ lib.optional stdenv.isDarwin [ nix-darwin.packages.${system}.darwin-rebuild ];
              shellHook = ''export EDITOR=nvim'';
            };
        };
    in
    {
      devShells = forAllSystems devShell;
      packages = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.callPackage ./default.nix { };
      });

      darwinConfigurations =
        let
          my-nix-homebrew =
            { user, lib, ... }:
            nix-homebrew.darwinModules.nix-homebrew {
              inherit lib;
              nix-homebrew = {
                inherit user;
                enable = true;
                mutableTaps = false;
                taps = with inputs; {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                  "homebrew/homebrew-bundle" = homebrew-bundle;
                  "nikitabobko/homebrew-tap" = homebrew-aerospace;
                  "zkondor/homebrew-dist" = homebrew-zkondor;
                };
              };
            };
        in
        {
          m3 = nix-darwin.lib.darwinSystem {
            system = "aarch64-darwin";
            specialArgs = {
              inherit inputs;
            };
            modules = [ ./hosts/m3 ];
          };

          gkr =
            let
              name = "Genki";
              user = "genki";
              userName = "Genki builder";
              userEmail = "genki@genkiinstruments.com";
              host = "gkr";
              system = "aarch64-darwin";
            in
            nix-darwin.lib.darwinSystem {
              system = "aarch64-darwin";
              specialArgs = {
                inherit
                  inputs
                  user
                  name
                  userEmail
                  host
                  secrets
                  ;
              };
              modules = [
                {
                  imports = [
                    home-manager.darwinModules.home-manager
                    agenix.darwinModules.default
                    my-nix-homebrew
                    ./modules/shared
                    ./hosts/gkr
                  ];
                  age = {
                    identityPaths = [
                      # Generate manually via `sudo ssh-keygen -A /etc/ssh/` on macOS, using the host key for decryption
                      "/etc/ssh/ssh_host_ed25519_key"
                    ];
                  };
                  # I'm currently managing the github runner manually.. didn't get it to work properly with nix-darwin...
                  home-manager.useGlobalPkgs = true;
                  home-manager.useUserPackages = true;
                  home-manager.backupFileExtension = "backup";
                  home-manager.users.${user} =
                    { config, ... }:
                    {
                      imports = [
                        nix-index-database.hmModules.nix-index
                        catppuccin.homeManagerModules.catppuccin
                        ./modules/shared/home.nix
                      ];
                      catppuccin = {
                        enable = true;
                        flavor = "mocha";
                      };
                      programs.git = {
                        inherit userEmail userName;
                      };
                      home.file.".config/karabiner/karabiner.json".source = config.lib.file.mkOutOfStoreSymlink ./modules/darwin/config/karabiner/karabiner.json; # Hyper-key config
                    };
                  users.users.${user} =
                    { pkgs, ... }:
                    {
                      shell = "/run/current-system/sw/bin/fish";
                      isHidden = false;
                      home = "/Users/${user}";
                    };
                  environment.systemPackages = with nixpkgs.legacyPackages.${system}; [ openssh ]; # needed for fido2 support
                  nix.settings.trusted-users = [
                    "root"
                    "@wheel"
                    "${user}"
                  ]; # Otherwise we get complaints
                  programs.fish.enable = true; # Otherwise our shell won't be installed correctly
                }
              ];
            };
        };

      nixosConfigurations = {
        gdrn = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules = [ ./hosts/gdrn ];
        };
        gugusar =
          let
            user = "genki";
            userName = "Ólafur Bjarki Bogason";
            userEmail = "olafur@genkiinstruments.com";
          in
          nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              {
                imports = [
                  home-manager.nixosModules.home-manager
                  disko.nixosModules.disko
                  ./modules/shared
                ];
                disko.devices = {
                  disk = {
                    main = {
                      device = "/dev/disk/by-id/ata-TOSHIBA_KSG60ZMV256G_M.2_2280_256GB_583B83NWK5SP";
                      type = "disk";
                      content = {
                        type = "gpt";
                        partitions = {
                          boot = {
                            size = "1M";
                            type = "EF02"; # for grub MBR
                          };
                          ESP = {
                            size = "1G";
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
                boot = {
                  loader.systemd-boot.enable = true;
                  loader.efi.canTouchEfiVariables = true;
                  initrd.availableKernelModules = [
                    "xhci_pci"
                    "ahci"
                    "usb_storage"
                    "sd_mod"
                  ];
                  kernelModules = [ "kvm-intel" ];
                };
                networking.hostName = "gugusar";
                networking.useDHCP = true;
                users.users.${user} = {
                  isNormalUser = true;
                  shell = "/run/current-system/sw/bin/fish";
                  openssh.authorizedKeys.keyFiles = [ ./authorized_keys ];
                  extraGroups = [ "wheel" ];
                  hashedPassword = "";
                };
                users.users.root.openssh.authorizedKeys.keyFiles = [ ./authorized_keys ];
                users.users.root.hashedPassword = "";
                security.sudo.execWheelOnly = true;
                security.sudo.wheelNeedsPassword = false;
                security.sudo.extraConfig = ''Defaults lecture = never'';
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.backupFileExtension = "backup";
                home-manager.users.${user} =
                  { config, ... }:
                  {
                    imports = [
                      nix-index-database.hmModules.nix-index
                      catppuccin.homeManagerModules.catppuccin
                      ./modules/shared/home.nix
                    ];
                    catppuccin = {
                      enable = true;
                      flavor = "mocha";
                    };
                    programs.git = {
                      inherit userEmail userName;
                    };
                  };
                programs.fish.enable = true; # Otherwise our shell won't be installed correctly
                services.tailscale.enable = true;
                services.openssh.enable = true;
                services.openssh.extraConfig = ''AllowAgentForwarding yes'';
                programs.ssh.startAgent = true;
                system.stateVersion = "23.05";
              }
            ];
          };
        kroli =
          let
            user = "genki";
            userName = "Ólafur Bjarki Bogason";
            userEmail = "olafur@genkiinstruments.com";
          in
          nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              {
                imports = [
                  home-manager.nixosModules.home-manager
                  disko.nixosModules.disko
                  ./modules/shared
                ];
                disko.devices = {
                  disk = {
                    main = {
                      device = "/dev/disk/by-id/ata-SanDisk_SD8SN8U512G1002_175124804870";
                      type = "disk";
                      content = {
                        type = "gpt";
                        partitions = {
                          boot = {
                            size = "1M";
                            type = "EF02"; # for grub MBR
                          };
                          ESP = {
                            size = "1G";
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
                boot = {
                  loader.systemd-boot.enable = true;
                  loader.efi.canTouchEfiVariables = true;
                  initrd.availableKernelModules = [
                    "xhci_pci"
                    "ahci"
                    "usb_storage"
                    "sd_mod"
                  ];
                  kernelModules = [ "kvm-intel" ];
                };
                networking.hostName = "kroli";
                networking.useDHCP = true;
                users.users.${user} = {
                  isNormalUser = true;
                  shell = "/run/current-system/sw/bin/fish";
                  openssh.authorizedKeys.keyFiles = [ ./authorized_keys ];
                  extraGroups = [ "wheel" ];
                  hashedPassword = "";
                };
                users.users.root.openssh.authorizedKeys.keyFiles = [ ./authorized_keys ];
                users.users.root.hashedPassword = "";
                security.sudo.execWheelOnly = true;
                security.sudo.wheelNeedsPassword = false;
                security.sudo.extraConfig = ''Defaults lecture = never'';
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.backupFileExtension = "backup";
                home-manager.users.${user} =
                  { config, ... }:
                  {
                    imports = [
                      nix-index-database.hmModules.nix-index
                      catppuccin.homeManagerModules.catppuccin
                      ./modules/shared/home.nix
                    ];
                    catppuccin = {
                      enable = true;
                      flavor = "mocha";
                    };
                    programs.git = {
                      inherit userEmail userName;
                    };
                  };
                programs.fish.enable = true; # Otherwise our shell won't be installed correctly
                services.tailscale.enable = true;
                services.openssh.enable = true;
                services.openssh.extraConfig = ''AllowAgentForwarding yes'';
                programs.ssh.startAgent = true;
                system.stateVersion = "23.05";
              }
            ];
          };
        biggimaus =
          let
            user = "genki";
            userName = "Ólafur Bjarki Bogason";
            userEmail = "olafur@genkiinstruments.com";
          in
          nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              {
                imports = [
                  srvos.nixosModules.server
                  srvos.nixosModules.mixins-systemd-boot
                  srvos.nixosModules.mixins-terminfo
                  srvos.nixosModules.mixins-nix-experimental
                  srvos.nixosModules.mixins-trusted-nix-caches
                  disko.nixosModules.disko
                  home-manager.nixosModules.home-manager
                  ./modules/shared
                  ./hosts/biggimaus/disko-config.nix
                ];
                disko.devices.disk.main.device = "/dev/disk/by-id/nvme-eui.002538db21a8a97f";
                boot = {
                  loader.systemd-boot.enable = true;
                  loader.efi.canTouchEfiVariables = true;
                  binfmt.emulatedSystems = [ "aarch64-linux" ];
                  initrd.availableKernelModules = [
                    "xhci_pci"
                    "ahci"
                    "nvme"
                    "usbhid"
                    "usb_storage"
                    "sd_mod"
                  ];
                  kernelModules = [ "kvm-intel" ];
                };
                networking.hostName = "biggimaus";
                networking.hostId = "deadbeef";
                networking.useDHCP = true;
                users.users.${user} = {
                  isNormalUser = true;
                  shell = "/run/current-system/sw/bin/fish";
                  openssh.authorizedKeys.keyFiles = [ ./authorized_keys ];
                  extraGroups = [ "wheel" ];
                };
                users.users.root.openssh.authorizedKeys.keyFiles = [ ./authorized_keys ];
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.backupFileExtension = "backup";
                home-manager.users.${user} =
                  { config, ... }:
                  {
                    imports = [
                      nix-index-database.hmModules.nix-index
                      catppuccin.homeManagerModules.catppuccin
                      ./modules/shared/home.nix
                    ];
                    catppuccin = {
                      enable = true;
                      flavor = "mocha";
                    };
                    programs.git = {
                      inherit userEmail userName;
                    };
                    programs.atuin.settings.daemon.enabled = true;
                  };
                programs.fish.enable = true; # Otherwise our shell won't be installed correctly
                services.tailscale.enable = true;
                system.stateVersion = "23.05";
              }
            ];
          };
        joip =
          let
            name = "Ólafur Bjarki Bogason";
            user = "olafur";
            userName = user;
            host = "joip";
            userEmail = "olafur@genkiinstruments.com";
          in
          nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {
              inherit
                inputs
                user
                host
                name
                userEmail
                secrets
                ;
            };
            modules = [
              {
                imports = [
                  srvos.nixosModules.server
                  nixos-hardware.nixosModules.intel-nuc-8i7beh
                  home-manager.nixosModules.home-manager
                  disko.nixosModules.disko
                  agenix.nixosModules.default
                  ./hosts/joip
                ];
                age = {
                  secrets = {
                    "my-secret" = {
                      symlink = true;
                      path = "/home/${user}/my-secret";
                      file = "${secrets}/my-secret.age";
                      mode = "644";
                      owner = "${user}";
                      group = "users";
                    };
                    dashboard-env = {
                      symlink = true;
                      file = "${secrets}/homepage-dashboard-env.age";
                      owner = "${user}";
                      group = "users";
                      mode = "644";
                    };
                    atuin-key = {
                      symlink = true;
                      path = "/home/${user}/.local/share/atuin/key";
                      file = "${secrets}/atuin-key.age";
                      mode = "644";
                      owner = "${user}";
                      group = "users";
                    };
                  };
                };
                users.users.${user} = {
                  isNormalUser = true;
                  shell = "/run/current-system/sw/bin/fish";
                  openssh.authorizedKeys.keyFiles = [ ./authorized_keys ];
                  extraGroups = [ "wheel" ];
                };
                users.users.root.openssh.authorizedKeys.keyFiles = [ ./authorized_keys ];
                nix.settings.trusted-users = [
                  "root"
                  "@wheel"
                  "${user}"
                ];
                networking.hostName = "joip";
                # Workaround https://github.com/NixOS/nixpkgs/issues/180175
                systemd.services.NetworkManager-wait-online.enable = false;
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.backupFileExtension = "backup";
                home-manager.users.${user} =
                  { config, ... }:
                  {
                    imports = [
                      nix-index-database.hmModules.nix-index
                      catppuccin.homeManagerModules.catppuccin
                      ./modules/shared/home.nix
                    ];
                    catppuccin = {
                      enable = true;
                      flavor = "mocha";
                    };
                    programs.git = {
                      inherit userEmail userName;
                    };
                  };
                programs.fish.enable = true; # Otherwise our shell won't be installed correctly
                system.stateVersion = "23.05";
              }
            ];
          };
      };
    };
}
