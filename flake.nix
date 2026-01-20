{
  description = "Genki 🌍🌎🌏";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable&shallow=1";
    # nixpkgs.url = "github:NixOS/nixpkgs?ref=master&shallow=1";

    srvos.url = "github:nix-community/srvos?shallow=1";
    srvos.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix?shallow=1";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.darwin.follows = "nix-darwin";
    agenix.inputs.home-manager.follows = "home-manager";

    blueprint.url = "github:numtide/blueprint?shallow=1";
    blueprint.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager?shallow=1";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:LnL7/nix-darwin/master?shallow=1";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko?shallow=1";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:nix-community/stylix?shallow=1";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    base16-schemes.url = "github:tinted-theming/schemes?shallow=1";
    base16-schemes.flake = false;

    stripe-webshippy-sync.url = "github:genkiinstruments/stripe-webshippy-sync?shallow=1";
    stripe-webshippy-sync.inputs.nixpkgs.follows = "nixpkgs";

    secrets.url = "github:genkiinstruments/nix-secrets?shallow=1";
    secrets.flake = false;

    treefmt-nix.url = "github:numtide/treefmt-nix?shallow=1";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    nixos-facter-modules.url = "github:nix-community/nixos-facter-modules?shallow=1";

    buildbot-nix.url = "github:nix-community/buildbot-nix?shallow=1";
    buildbot-nix.inputs.nixpkgs.follows = "nixpkgs";

    comin.url = "github:multivac61/comin/fix-darwin-status-v2?shallow=1";
    comin.inputs.nixpkgs.follows = "nixpkgs";

    # Apple Silicon support for m2
    nixos-apple-silicon.url = "github:tpwrules/nixos-apple-silicon?shallow=1";
    nixos-apple-silicon.inputs.nixpkgs.follows = "nixpkgs";

    neovim-nightly.url = "github:neovim/neovim?shallow=1";
    neovim-nightly.flake = false;

    yazi-flavors.url = "github:yazi-rs/flavors?shallow=1";
    yazi-flavors.flake = false;

    expert.url = "github:elixir-lang/expert?shallow=1";
    expert.inputs.nixpkgs.follows = "nixpkgs";
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
