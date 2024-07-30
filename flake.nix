{
  description = "Nix runs my 🌍🌎🌏";
  inputs = {
    srvos.url = "github:nix-community/srvos";
    nixpkgs.follows = "srvos/nixpkgs"; # use the version of nixpkgs that has been tested with SrvOS
    home-manager.url = "github:nix-community/home-manager";
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
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
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";
  };
  outputs = { self, srvos, darwin, nix-homebrew, home-manager, nixpkgs, nixos-hardware, nix-index-database, disko, catppuccin, ... } @inputs:
    let
      forAllSystems = f: nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ] f;
      devShell = system:
        let pkgs = nixpkgs.legacyPackages.${system}; in {
          default = with pkgs; mkShell {
            buildInputs = [ bashInteractive git nixos-anywhere age age-plugin-yubikey ] ++ lib.optional stdenv.isDarwin [ darwin.packages.${system}.darwin-rebuild ];
            shellHook = ''export EDITOR=nvim'';
          };
        };
    in
    {
      devShells = forAllSystems devShell;

      darwinConfigurations =
        let
          my-nix-homebrew = { user, lib, ... }:
            nix-homebrew.darwinModules.nix-homebrew
              {
                inherit lib;
                nix-homebrew = {
                  enable = true;
                  inherit user;
                  taps = with inputs; {
                    "homebrew/homebrew-core" = homebrew-core;
                    "homebrew/homebrew-cask" = homebrew-cask;
                    "homebrew/homebrew-bundle" = homebrew-bundle;
                  };
                  mutableTaps = false;
                  autoMigrate = true;
                };
              };
        in
        {
          m3 =
            let
              user = "olafur";
              userName = "Ólafur Bjarki Bogason";
              userEmail = "olafur@genkiinstruments.com";
              system = "aarch64-darwin";
            in
            darwin.lib.darwinSystem
              rec {
                inherit system;
                modules = [{
                  imports = [
                    # TODO: openssh.authorizedKeys.keyFiles has been deprecated in nix-darwin
                    # srvos.darwinModules.common
                    home-manager.darwinModules.home-manager
                    my-nix-homebrew
                    ./modules/shared
                    ./hosts/m3
                  ];
                  home-manager.useGlobalPkgs = true;
                  home-manager.useUserPackages = true;
                  home-manager.backupFileExtension = "backup";
                  home-manager.users.${user} = { config, ... }:
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
                      programs.git = { inherit userEmail userName; };
                      programs.ssh = {
                        matchBlocks = {
                          "github.com" = {
                            user = "git";
                            identityFile = "~/.ssh/id_ed25519_sk";
                            identitiesOnly = true;
                          };
                        };
                        forwardAgent = true;
                        addKeysToAgent = "yes";
                        extraConfig = "SetEnv TERM=xterm-256color";
                      };
                      programs.fish.interactiveShellInit = ''
                        ## https://gist.github.com/gerbsen/5fd8aa0fde87ac7a2cae
                        setenv SSH_ENV $HOME/.ssh/environment

                        function start_agent
                            echo "Initializing new SSH agent ..."
                            ssh-agent -c | sed 's/^echo/#echo/' > $SSH_ENV
                            echo "succeeded"
                            chmod 600 $SSH_ENV
                            . $SSH_ENV > /dev/null
                            ssh-add
                        end

                        function test_identities
                            ssh-add -l | grep "The agent has no identities" > /dev/null
                            if [ $status -eq 0 ]
                                ssh-add
                                if [ $status -eq 2 ]
                                    start_agent
                                end
                            end
                        end

                        if [ -n "$SSH_AGENT_PID" ]
                            ps -ef | grep $SSH_AGENT_PID | grep ssh-agent > /dev/null
                            if [ $status -eq 0 ]
                                test_identities
                            end
                        else
                            if [ -f $SSH_ENV ]
                                . $SSH_ENV > /dev/null
                            end
                            ps -ef | grep $SSH_AGENT_PID | grep -v grep | grep ssh-agent > /dev/null
                            if [ $status -eq 0 ]
                                test_identities
                            else
                                start_agent
                            end
                        end
                      '';
                      home.file.".config/karabiner/karabiner.json".source = config.lib.file.mkOutOfStoreSymlink ./modules/darwin/config/karabiner/karabiner.json; # Hyper-key config
                    };
                  users.users.${user} = { pkgs, ... }: {
                    shell = "/run/current-system/sw/bin/fish";
                    isHidden = false;
                    home = "/Users/${user}";
                  };
                  environment.systemPackages = with nixpkgs.legacyPackages.${system}; [ openssh ]; # needed for fido2 support
                  environment.variables.SSH_ASKPASS = "/usr/local/bin/ssh-askpass"; # TODO: Bring to nixpkgs https://github.com/theseal/ssh-askpass
                  environment.variables.DISPLAY = ":0";
                  nix.settings.trusted-users = [ "root" "@wheel" "${user}" ]; # Otherwise we get complaints
                  programs.fish.enable = true; # Otherwise our shell won't be installed correctly
                }];
              };

          gkr =
            let
              name = "Genki";
              user = "genki";
              userEmail = "olafur@genkiinstruments.com";
              host = "gkr";
            in
            darwin.lib.darwinSystem
              {
                system = "aarch64-darwin";
                specialArgs = { inherit inputs user name userEmail host; };
                modules = [
                  home-manager.darwinModules.home-manager
                  my-nix-homebrew
                  ./hosts/gkr
                ];
              };
          d =
            let
              name = "Daniel Gretarsson";
              user = "genki";
              userEmail = "daniel@genkiinstruments.com";
              host = "d";
            in
            darwin.lib.darwinSystem
              {
                system = "aarch64-darwin";
                specialArgs = { inherit inputs user name userEmail host; };
                modules = [
                  home-manager.darwinModules.home-manager
                  my-nix-homebrew
                  ./hosts/d
                ];
              };
        };

      nixosConfigurations = {
        gdrn =
          let
            user = "genki";
            userName = "Ólafur Bjarki Bogason";
            userEmail = "olafur@genkiinstruments.com";
          in
          nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [{
              imports = [
                srvos.nixosModules.server
                srvos.nixosModules.mixins-systemd-boot
                srvos.nixosModules.mixins-terminfo
                srvos.nixosModules.mixins-nix-experimental
                srvos.nixosModules.mixins-trusted-nix-caches
                disko.nixosModules.disko
                home-manager.nixosModules.home-manager
                ./modules/shared
                ./hosts/gdrn
              ];
              users.users.${user} = {
                isNormalUser = true;
                shell = "/run/current-system/sw/bin/fish";
                description = "${userName}";
                extraGroups = [ "networkmanager" "wheel" "docker" ];
                openssh.authorizedKeys.keyFiles = [ ./authorized_keys ];
              };
              users.users.root.openssh.authorizedKeys.keyFiles = [ ./authorized_keys ];
              networking.hostName = "gdrn";
              networking.hostId = "deadbeef";
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.${user} = { config, ... }:
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
                  programs.git = { inherit userEmail userName; };
                };
              programs.fish.enable = true;
              services.openssh.extraConfig = ''AllowAgentForwarding yes'';
              programs.ssh.startAgent = true;
            }];
          };
        gugusar =
          let
            user = "genki";
            userName = "Ólafur Bjarki Bogason";
            userEmail = "olafur@genkiinstruments.com";
          in
          nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [{
              imports = [
                home-manager.nixosModules.home-manager
                disko.nixosModules.disko
                ./modules/shared
              ];
              disko.devices = {
                disk = {
                  main = {
                    device = "/dev/disk/by-id/ata-TOSHIBA_KSG60ZMV256G_M.2_2280_256GB_583B83NWK5S";
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
                initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" ];
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
              home-manager.users.${user} = { config, ... }:
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
                  programs.git = { inherit userEmail userName; };
                };
              programs.fish.enable = true; # Otherwise our shell won't be installed correctly
              services.tailscale.enable = true;
              services.openssh.enable = true;
              services.openssh.extraConfig = ''AllowAgentForwarding yes'';
              programs.ssh.startAgent = true;
              system.stateVersion = "23.05";
            }];
          };
        kroli =
          let
            user = "genki";
            userName = "Ólafur Bjarki Bogason";
            userEmail = "olafur@genkiinstruments.com";
          in
          nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [{
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
                initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" ];
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
              home-manager.users.${user} = { config, ... }:
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
                  programs.git = { inherit userEmail userName; };
                };
              programs.fish.enable = true; # Otherwise our shell won't be installed correctly
              services.tailscale.enable = true;
              services.openssh.enable = true;
              services.openssh.extraConfig = ''AllowAgentForwarding yes'';
              programs.ssh.startAgent = true;
              system.stateVersion = "23.05";
            }];
          };
        biggimaus =
          let
            user = "genki";
            userName = "Ólafur Bjarki Bogason";
            userEmail = "olafur@genkiinstruments.com";
          in
          nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [{
              imports = [
                srvos.nixosModules.server
                srvos.nixosModules.mixins-systemd-boot
                srvos.nixosModules.mixins-terminfo
                srvos.nixosModules.mixins-nix-experimental
                srvos.nixosModules.mixins-trusted-nix-caches
                disko.nixosModules.disko
                home-manager.nixosModules.home-manager
                ./modules/shared
                ./hosts/biggimaus
                ./hosts/biggimaus/disko-config.nix
              ];
              disko.devices.disk.main.device = "/dev/disk/by-id/nvme-eui.002538db21a8a97f";
              boot = {
                loader.systemd-boot.enable = true;
                loader.efi.canTouchEfiVariables = true;
                binfmt.emulatedSystems = [ "aarch64-linux" ];
                initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
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
              home-manager.users.${user} = { config, ... }:
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
                  programs.git = { inherit userEmail userName; };
                  programs.atuin.settings.daemon.enabled = true; # https://github.com/atuinsh/atuin/issues/952#issuecomment-2199964530
                };
              programs.fish.enable = true; # Otherwise our shell won't be installed correctly
              services.tailscale.enable = true;
              system.stateVersion = "23.05";
            }];
          };
        joip =
          let
            name = "Ólafur Bjarki Bogason";
            user = "olafur";
            host = "joip";
            userEmail = "olafur@genkiinstruments.com";
          in
          nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = { inherit inputs user host name userEmail; };
            modules = [
              nixos-hardware.nixosModules.intel-nuc-8i7beh
              home-manager.nixosModules.home-manager
              disko.nixosModules.disko
              ./hosts/joip
            ];
          };
      };
    };
}
