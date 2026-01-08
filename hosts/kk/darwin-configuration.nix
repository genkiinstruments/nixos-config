{
  inputs,
  pkgs,
  flake,
  config,
  ...
}:
{
  imports = [
    inputs.srvos.darwinModules.desktop
    inputs.srvos.darwinModules.mixins-trusted-nix-caches
    inputs.agenix.darwinModules.default
    flake.modules.shared.stylix
    flake.modules.darwin.default
    flake.modules.darwin.user
    flake.modules.darwin.comin
    flake.modules.shared.default
    flake.modules.shared.home-manager
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.${config.genki.user}.openssh.authorizedKeys.keyFiles = [ "${flake}/authorized_keys" ];

  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 30d";
  nix.optimise.automatic = true;

  # Generate manually via `sudo ssh-keygen -A /etc/ssh/` on macOS, using the host key for decryption
  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  # Needed for Github runner?
  environment.systemPackages = with pkgs; [
    openssh
    gh
  ];

  # Create the nix-ssh user for remote builds - rely on Tailscale SSH for authentication
  # NOTE: Have to manually create the user on macOS. Does not need to be an administrator
  users.users.nix-ssh = {
    shell = pkgs.bash;
    isHidden = false;
    home = "/Users/nix-ssh";
    createHome = true;
  };
  nix.settings.trusted-users = [ "nix-ssh" ]; # genki added by module

  # Determinate Systems installer uses GID 350, nix-darwin expects 30000
  ids.gids.nixbld = 350;
}
