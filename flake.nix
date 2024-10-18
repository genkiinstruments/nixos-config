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
        biggimaus = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = [ ./hosts/biggimaus ];
        };
        joip = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = [ ./hosts/joip ];
        };
      };
    };
}
