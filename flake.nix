{
  description = "Nix runs my 🌍🌎🌏";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    srvos.url = "github:nix-community/srvos";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
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
  outputs = { self, srvos, darwin, nix-homebrew, home-manager, nixpkgs, nixpkgs-stable, nixos-hardware, nix-index-database, disko, catppuccin, ... } @inputs:
    let
      forAllSystems = f: nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ] f;
      devShell = system:
        let pkgs = nixpkgs.legacyPackages.${system}; in {
          default = with pkgs; mkShell {
            nativeBuildInputs = [ bashInteractive git nixos-anywhere ];
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
            in
            darwin.lib.darwinSystem
              rec {
                system = "aarch64-darwin";
                specialArgs.pkgs-stable = import nixpkgs-stable { inherit system; config.allowUnfree = true; };
                modules = [
                  srvos.darwinModules.common
                  home-manager.darwinModules.home-manager
                  {
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
                        home.file.".config/karabiner/karabiner.json".source = config.lib.file.mkOutOfStoreSymlink ./modules/darwin/config/karabiner/karabiner.json; # Hyper-key config
                      };
                  }
                  {
                    users.users.${user} = { pkgs, ... }: {
                      shell = "/run/current-system/sw/bin/fish";
                      isHidden = false;
                      home = "/Users/${user}";
                    };
                  }
                  {
                    nix.settings.trusted-users = [ "root" "@wheel" "${user}" ];
                    programs.fish.enable = true;
                  }
                  my-nix-homebrew
                  ./modules/shared
                  ./hosts/m3
                ];
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
            name = "Ólafur Bjarki Bogason";
            user = "genki";
            userEmail = "olafur@genkiinstruments.com";
          in
          nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = { inherit user name userEmail; };
            modules = [{
              imports = [
                srvos.nixosModules.common
                srvos.nixosModules.mixins-systemd-boot
                srvos.nixosModules.mixins-terminfo
                srvos.nixosModules.mixins-nix-experimental
                srvos.nixosModules.mixins-trusted-nix-caches
                disko.nixosModules.disko
                home-manager.nixosModules.home-manager
                ./hosts/gdrn
              ];
              networking.hostName = "gdrn";
              networking.hostId = "deadbeef";
            }];
          };
        biggimaus =
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
                ./hosts/biggimaus/disko-config.nix
              ];
              boot = {
                loader.systemd-boot.enable = true;
                loader.efi.canTouchEfiVariables = true;
                binfmt.emulatedSystems = [ "aarch64-linux" ];
                initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
                initrd.kernelModules = [ ];
                kernelModules = [ "kvm-intel" ];
                extraModulePackages = [ ];
              };
              networking.hostName = "biggimaus";
              networking.hostId = "deadbeef";
              services.tailscale.enable = true;
              disko.devices.disk.main.device = "/dev/disk/by-id/nvme-eui.002538db21a8a97f";
              users.users.genki = {
                isNormalUser = true;
                openssh.authorizedKeys.keyFiles = [ ./authorized_keys ];
                extraGroups = [ "networkmanager" "wheel" ];
                initialHashedPassword = "";
              };
              users.users.root.openssh.authorizedKeys.keyFiles = [ ./authorized_keys ];
              system.stateVersion = "23.05";
              networking.useDHCP = true;
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
