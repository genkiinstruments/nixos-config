{
  description = "Nix runs my 🌍🌎🌏";
  inputs = {
    srvos.url = "github:nix-community/srvos";
    nixpkgs.follows = "srvos/nixpkgs"; # use the version of nixpkgs that has been tested with SrvOS
    blueprint.url = "github:numtide/blueprint";
    blueprint.inputs.nixpkgs.follows = "nixpkgs";
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
  outputs = inputs: inputs.blueprint { inherit inputs; };
}
