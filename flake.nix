{
  description = "Nix runs my 🌍🌎🌏";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, darwin, nix-homebrew, homebrew-bundle, homebrew-core, homebrew-cask, home-manager, nixpkgs, disko } @inputs:
    let
      linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
      darwinSystems = [ "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs (linuxSystems ++ darwinSystems) f;
      devShell = system:
        let pkgs = nixpkgs.legacyPackages.${system}; in {
          default = with pkgs; mkShell {
            nativeBuildInputs = [ bashInteractive git ];
            shellHook = ''export EDITOR=nvim'';
          };
        };
      mkApp = scriptName: host: system: {
        type = "app";
        program = "${(nixpkgs.legacyPackages.${system}.writeScriptBin scriptName ''
          #!/usr/bin/env bash
          PATH=${nixpkgs.legacyPackages.${system}.git}/bin:$PATH
          echo "Running ${scriptName} for ${system}"
          exec ${self}/apps/${system}/${host}/${scriptName}
        '')}/bin/${scriptName}";
      };
      mkLinuxApps = system: {
        "gdrn" = mkApp "build-switch" "gdrn" system;
      };
      mkDarwinApps = system: {
        "m3" = mkApp "build-switch" "m3" system;
      };
    in
    {
      devShells = forAllSystems devShell;
      apps = nixpkgs.lib.genAttrs linuxSystems mkLinuxApps // nixpkgs.lib.genAttrs darwinSystems mkDarwinApps;

      darwinConfigurations =
        {
          m3 =
            let
              name = "Ólafur Bjarki Bogason";
              user = "olafur";
              email = "olafur@genkiinstruments.com";
            in
            darwin.lib.darwinSystem
              {
                system = "aarch64-darwin";
                specialArgs = { inherit inputs user name email; };
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
            modules = [
              disko.nixosModules.disko
              home-manager.nixosModules.home-manager
              ./hosts/gdrn
            ];
          };
      };
    };
}
