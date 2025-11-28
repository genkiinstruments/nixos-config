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

    stripe-webshippy-sync.url = "github:genkiinstruments/stripe-webshippy-sync";
    stripe-webshippy-sync.inputs.nixpkgs.follows = "nixpkgs";

    secrets.url = "github:genkiinstruments/nix-secrets";
    secrets.flake = false;

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    nixos-facter-modules.url = "github:nix-community/nixos-facter-modules";

    buildbot-nix.url = "github:nix-community/buildbot-nix";
    buildbot-nix.inputs.nixpkgs.follows = "nixpkgs";

    comin.url = "github:nlewo/comin";
    comin.inputs.nixpkgs.follows = "nixpkgs";

    # Apple Silicon support for m2
    nixos-apple-silicon.url = "github:tpwrules/nixos-apple-silicon";
    nixos-apple-silicon.inputs.nixpkgs.follows = "nixpkgs";

    nix-ai-tools.url = "github:numtide/nix-ai-tools";
    nix-ai-tools.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs:

    # Call a library function to do a recursive merge to blueprint
    # with my own attributes.
    inputs.nixpkgs.lib.attrsets.recursiveUpdate

      # Load blueprint.
      (inputs.blueprint {
        inherit inputs;
        systems = [
          "aarch64-darwin"
          "aarch64-linux"
          "x86_64-linux"
        ];
      })

      # And depclare my own things that gets recursivly merged with
      # blueprint so they don't overwrite each other.
      (
        let
          # Functions to create deplayable nodes with deploy-rs
          mkDeploy =
            {
              name,
              sshUser ? "root",
              system ? "x86_64-linux",
            }:
            {
              inherit sshUser;
              hostname = "${name}.tail01dbd.ts.net";
              profiles.system.path =
                inputs.deploy-rs.lib.${system}.activate.nixos
                  inputs.self.nixosConfigurations.${name};
            };

          # Declare deployable nodes
          deploy.nodes = {
            gdrn = mkDeploy { name = "gdrn"; };
            x = mkDeploy { name = "x"; };
            m2 = mkDeploy {
              name = "m2";
              system = "aarch64-linux";
            };
            pbt = mkDeploy {
              name = "pbt";
              system = "aarch64-linux";
            };
          };

          # This is highly advised, and will prevent many possible mistakes
          checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks deploy) inputs.deploy-rs.lib;
        in
        {
          inherit deploy checks;
        }
      );
}
