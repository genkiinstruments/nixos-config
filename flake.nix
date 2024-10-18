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
      specialArgs = {
        inherit inputs;
      };
    in
    {
      devShells = forAllSystems devShell;
      packages = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.callPackage ./default.nix { };
      });

      darwinConfigurations = {
        m3 = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          inherit specialArgs;
          modules = [ ./hosts/m3 ];
        };

        gkr = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          inherit specialArgs;
          modules = [ ./hosts/gkr ];
        };
      };

      nixosConfigurations = {
        gdrn = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = [ ./hosts/gdrn ];
        };
        gugusar = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = [ ./hosts/gugusar ];
        };
        kroli = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = [ ./hosts/kroli ];
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
        biggimaus = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = [ ./hosts/biggimaus ];
        };
      };
    };
}
