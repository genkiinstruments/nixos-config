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
  outputs = { self, srvos, darwin, nix-homebrew, homebrew-bundle, homebrew-core, homebrew-cask, home-manager, nixpkgs, nixpkgs-stable, nixos-hardware, nix-index-database, disko, catppuccin } @inputs:
    let
      linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
      darwinSystems = [ "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs (linuxSystems ++ darwinSystems) f;
      devShell = system:
        let pkgs = nixpkgs.legacyPackages.${system}; in {
          default = with pkgs; mkShell {
            nativeBuildInputs = [ bashInteractive git nixos-anywhere ];
            shellHook = ''export EDITOR=nvim'';
          };
        };
      mkApp = scriptName: host: system: {
        type = "app";
        program = "${(nixpkgs.legacyPackages.${system}.writeScriptBin scriptName ''
          #!/usr/bin/env bash
          PATH=${nixpkgs.legacyPackages.${system}.git}/bin:$PATH
          echo "Running ${scriptName} for ${system}"
          HOST="${host}" ${self}/apps/${system}/${scriptName}
        '')}/bin/${scriptName}";
      };
      mkDarwinApps = system: {
        "m3" = mkApp "build-switch" "m3" system;
        "d" = mkApp "build-switch" "d" system;
        "gkr" = mkApp "build-switch" "gkr" system;
      };
    in
    rec {
      devShells = forAllSystems devShell;
      apps = nixpkgs.lib.genAttrs darwinSystems mkDarwinApps;

      darwinConfigurations =
        {
          m3 =
            let
              name = "Ólafur Bjarki Bogason";
              user = "olafur";
              email = "olafur@genkiinstruments.com";
            in
            darwin.lib.darwinSystem
              rec {
                system = "aarch64-darwin";
                specialArgs = {
                  inherit inputs user name email;
                  pkgs-stable = import nixpkgs-stable { inherit system; config.allowUnfree = true; };
                };
                modules = [
                  home-manager.darwinModules.home-manager
                  nix-homebrew.darwinModules.nix-homebrew
                  {
                    nix-homebrew = {
                      enable = true;
                      inherit user;
                      taps = {
                        "homebrew/homebrew-core" = homebrew-core;
                        "homebrew/homebrew-cask" = homebrew-cask;
                        "homebrew/homebrew-bundle" = homebrew-bundle;
                      };
                      mutableTaps = false;
                      autoMigrate = true;
                    };
                  }
                  ./hosts/m3
                ];
              };
          gkr =
            let
              name = "Genki";
              user = "genki";
              email = "olafur@genkiinstruments.com";
              host = "gkr";
            in
            darwin.lib.darwinSystem
              {
                system = "aarch64-darwin";
                specialArgs = { inherit inputs user name email host; };
                modules = [
                  home-manager.darwinModules.home-manager
                  nix-homebrew.darwinModules.nix-homebrew
                  {
                    nix-homebrew = {
                      enable = true;
                      inherit user;
                      taps = {
                        "homebrew/homebrew-core" = homebrew-core;
                        "homebrew/homebrew-cask" = homebrew-cask;
                        "homebrew/homebrew-bundle" = homebrew-bundle;
                      };
                      mutableTaps = false;
                      autoMigrate = true;
                    };
                  }
                  ./hosts/gkr
                ];
              };
          d =
            let
              name = "Daniel Gretarsson";
              user = "genki";
              email = "daniel@genkiinstruments.com";
              host = "d";
            in
            darwin.lib.darwinSystem
              {
                system = "aarch64-darwin";
                specialArgs = { inherit inputs user name email host; };
                modules = [
                  home-manager.darwinModules.home-manager
                  nix-homebrew.darwinModules.nix-homebrew
                  {
                    nix-homebrew = {
                      enable = true;
                      inherit user;
                      taps = {
                        "homebrew/homebrew-core" = homebrew-core;
                        "homebrew/homebrew-cask" = homebrew-cask;
                        "homebrew/homebrew-bundle" = homebrew-bundle;
                      };
                      mutableTaps = false;
                      autoMigrate = true;
                    };
                  }
                  ./hosts/d
                ];
              };
        };

      nixosConfigurations = {
        gdrn =
          let
            name = "Ólafur Bjarki Bogason";
            user = "genki";
            email = "olafur@genkiinstruments.com";
          in
          nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = { inherit inputs user name email; };
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
                openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ1uxevLNJOPIPRMh9G9fFSqLtYjK5R7+nRdtsas2KwX olafur@M3.localdomain" ];
                extraGroups = [ "networkmanager" "wheel" ];
                initialHashedPassword = "";
              };
              system.stateVersion = "23.05";
              networking.useDHCP = true;
            }];
          };
        nix-deployment =
          let
            name = "Ólafur Bjarki Bogason";
            user = "genki";
            host = "nix-deployment";
            email = "olafur@genkiinstruments.com";
          in
          nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            specialArgs = { inherit inputs user host name email; };
            modules = [
              nixos-hardware.nixosModules.raspberry-pi-4
              home-manager.nixosModules.home-manager
              "${nixpkgs}/nixos/modules/profiles/minimal.nix"
              ./hosts/nix-deployment/configuration.nix
            ];
          };
        joip =
          let
            name = "Ólafur Bjarki Bogason";
            user = "olafur";
            host = "joip";
            email = "olafur@genkiinstruments.com";
          in
          nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = { inherit inputs user host name email; };
            modules = [
              nixos-hardware.nixosModules.intel-nuc-8i7beh
              home-manager.nixosModules.home-manager
              disko.nixosModules.disko
              ./hosts/joip
            ];
          };
      };

      images = {
        nix-deployment = (self.nixosConfigurations.nix-deployment.extendModules {
          modules = [
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            {
              disabledModules = [ "profiles/base.nix" ];
              sdImage.compressImage = false;
            }
          ];
        }).config.system.build.sdImage;
      };
      packages.x86_64-linux.nix-deployment-image = images.nix-deployment;
      packages.aarch64-linux.nix-deployment-image = images.nix-deployment;
    };
}
