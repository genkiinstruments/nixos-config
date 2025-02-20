{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.srvos.darwinModules.common
    inputs.srvos.darwinModules.mixins-telegraf
    inputs.srvos.darwinModules.mixins-terminfo
    inputs.srvos.darwinModules.mixins-nix-experimental
    inputs.agenix.darwinModules.default
    inputs.self.darwinModules.common
    inputs.self.modules.shared.default
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  # Generate manually via `sudo ssh-keygen -A /etc/ssh/` on macOS, using the host key for decryption
  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  users.users.genki = {
    shell = pkgs.fish;
    isHidden = false;
    home = "/Users/genki";
    openssh.authorizedKeys.keyFiles = [ ../../authorized_keys ];
  };
  environment.systemPackages = with pkgs; [ openssh ]; # needed for fido2 support

  nix.settings.trusted-users = [
    "root"
    "@wheel"
    "genki"
  ];

  # TODO: This really is a hack to run actions-runner that was
  # manually installed using: https://github.com/organizations/genkiinstruments/settings/actions/runners/new?arch=arm64&os=osx
  # under folder /Users/genki/actions-runner. The reason we do this is because the github-actions runner
  # in nix-darwin - https://daiderd.com/nix-darwin/manual/index.html#opt-services.github-runners - runs inside a nix container
  # and as such has no acccess to Apple clang and other dependencies needed.
  # Don't run automatic gc as it may break the actions-runner code.
  launchd.daemons.github-runner = {
    serviceConfig = {
      ProgramArguments = [
        "/bin/sh"
        "-c"
        # follow exact steps of github guide to get this available
        # so more automatic nix version would use pkgs.github-runner (and token sshed as file)
        "/Users/genki/actions-runner/run.sh"
      ];
      Label = "github-runner";
      KeepAlive = true;
      RunAtLoad = true;

      StandardErrorPath = "/Users/genki/actions-runner/err.log";
      StandardOutPath = "/Users/genki/actions-runner/ok.log";
      WorkingDirectory = "/Users/genki/actions-runner/";
      SessionCreate = true;
      UserName = "genki";
    };
  };
}
