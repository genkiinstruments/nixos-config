{
  description = "Nix runs my 🌍🌎🌏";

  inputs = {
    srvos.url = "github:nix-community/srvos";
    nixpkgs.follows = "srvos/nixpkgs"; # use the version of nixpkgs that has been tested with SrvOS
    blueprint.url = "github:numtide/blueprint";
    blueprint.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    catppuccin.url = "github:catppuccin/nix";
    agenix.url = "github:ryantm/agenix";
    secrets.url = "git+ssh://git@github.com/multivac61/nix-secrets.git";
    secrets.flake = false;
    mvim.url = "github:multivac61/mvim";
    mvim.flake = false;
  };

  outputs = inputs: inputs.blueprint { inherit inputs; };
}
