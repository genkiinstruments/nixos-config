{
  description = "Genki 🌍🌎🌏";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable&shallow=1";
    # nixpkgs.url = "github:NixOS/nixpkgs?ref=master&shallow=1";

    srvos.url = "github:nix-community/srvos";
    srvos.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.darwin.follows = "nix-darwin";
    agenix.inputs.home-manager.follows = "home-manager";

    blueprint.url = "github:numtide/blueprint";
    blueprint.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    catppuccin.url = "github:catppuccin/nix";
    catppuccin.inputs.nixpkgs.follows = "nixpkgs";

    secrets.url = "github:genkiinstruments/nix-secrets";
    secrets.flake = false;

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    nixos-facter-modules.url = "github:nix-community/nixos-facter-modules";

    # The module applies custom patches that only apply to buildbot > 4.0.0.
    # To use buildbot-nix with NixOS 24.05, you should therefore not override the nixpkgs input to your own stable version of buildbot-nix.
    buildbot-nix.url = "github:nix-community/buildbot-nix?rev=d8a24c100e798bf1f938926ccee3d0430f7c3f63";

    genki-www.url = "github:genkiinstruments/genki-www";
    genki-www.inputs.nixpkgs.follows = "nixpkgs";
    genki-www.inputs.blueprint.follows = "blueprint";

    fod-oracle.url = "github:multivac61/fod-oracle";
    fod-oracle.inputs.nixpkgs.follows = "nixpkgs";
    fod-oracle.inputs.blueprint.follows = "blueprint";

    comin.url = "github:multivac61/comin";
    comin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs:
    inputs.blueprint {
      inherit inputs;
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
    };
}
