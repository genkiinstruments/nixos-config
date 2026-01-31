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

    hercules-ci-effects.url = "github:hercules-ci/hercules-ci-effects?shallow=1";
    hercules-ci-effects.inputs.nixpkgs.follows = "nixpkgs";

    # Apple Silicon support for m2
    nixos-apple-silicon.url = "github:tpwrules/nixos-apple-silicon?shallow=1";
    nixos-apple-silicon.inputs.nixpkgs.follows = "nixpkgs";

    neovim-nightly.url = "github:neovim/neovim?shallow=1";
    neovim-nightly.flake = false;

    yazi-flavors.url = "github:yazi-rs/flavors?shallow=1";
    yazi-flavors.flake = false;

    expert.url = "github:elixir-lang/expert?shallow=1";
    expert.inputs.nixpkgs.follows = "nixpkgs";

    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs =
    inputs:
    let
      blueprintOutputs = inputs.blueprint {
        inherit inputs;
        systems = [
          "aarch64-darwin"
          "aarch64-linux"
          "x86_64-linux"
        ];
      };
    in
    blueprintOutputs
    // {
      herculesCI = herculesCI: {
        onPush.default.outputs.effects =
          let
            pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
            effects = inputs.hercules-ci-effects.lib.withPkgs pkgs;

            nixosHosts = [
              # "g" # TODO: add back when online, need to get host key
              "gdrn"
              "joip"
              "kroli"
              "m2"
              "pbt"
              "x"
            ];
            darwinHosts = [
              "gkr"
              "kk"
            ];

            mkEffect =
              hostname: isNixOS:
              effects.runIf (herculesCI.config.repo.branch == "main") (
                (if isNixOS then effects.runNixOS else effects.runNixDarwin) {
                  configuration =
                    blueprintOutputs.${if isNixOS then "nixosConfigurations" else "darwinConfigurations"}.${hostname};
                  ssh.destination = "nix-ssh@${hostname}.tail01dbd.ts.net";
                  secretsMap.ssh = "deploy-ssh";
                  userSetupScript = ''
                    writeSSHKey ssh
                    cat >>~/.ssh/known_hosts <<'EOF'
                    gdrn.tail01dbd.ts.net ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHRXFsRbLcgKBiszr7aZoJ9SkwWVz0TMMmH/DKvrHyg6
                    joip.tail01dbd.ts.net ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICi0oBVUyokeykTB8O221FTA0zl5bKVEttR/GgJ68A0Q
                    kroli.tail01dbd.ts.net ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPdXqvprgwgaZLdzE1mK2au74pG/OpyQOgcEsnsrvIaG
                    m2.tail01dbd.ts.net ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIeLtQzCCCvpihz5d55/42RcfbCuyvmyz8a2m19c5I4M
                    pbt.tail01dbd.ts.net ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPDFr5kBziO5LGitZX6A2Dj4cP3JH/wRG0uTw8xt0vdb
                    x.tail01dbd.ts.net ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBBtnJ1eS+mI4EASAWk7NXin5Hln0ylYUPHe2ovQAa8G
                    gkr.tail01dbd.ts.net ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDjZskQnQNJl5ndUTXFmc8c05/RaOHb/grNOgfnDap6+
                    kk.tail01dbd.ts.net ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINdj4iMvaB2/pElSeEP1bKvaDq6nFzVW6olk+W6fP5kr
                    EOF
                  '';
                }
              );
          in
          builtins.listToAttrs (
            (map (h: {
              name = "deploy-${h}";
              value = mkEffect h true;
            }) nixosHosts)
            ++ (map (h: {
              name = "deploy-${h}";
              value = mkEffect h false;
            }) darwinHosts)
          );
      };
    };
}
