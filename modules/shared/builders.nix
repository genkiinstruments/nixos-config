{
  lib,
  flake,
  ...
}:
let
  inherit (flake.lib) tailnet;

  mkBuilder =
    {
      hostName,
      systems,
      maxJobs,
    }:
    {
      inherit
        hostName
        systems
        maxJobs
        ;
      sshUser = "nix-ssh";
      protocol = "ssh-ng";
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];
    };

  mkSshConfig = hostName: ''
    Host ${hostName} ${hostName}.${tailnet}
      User nix-ssh
      HostName ${hostName}.${tailnet}
      StrictHostKeyChecking accept-new
      BatchMode yes
      PubkeyAuthentication yes
      IdentitiesOnly yes
  '';

  builders = [
    (mkBuilder {
      hostName = "gdrn";
      systems = [ "x86_64-linux" ];
      maxJobs = 32;
    })
    (mkBuilder {
      hostName = "x";
      systems = [ "x86_64-linux" ];
      maxJobs = 32;
    })
    (mkBuilder {
      hostName = "pbt";
      systems = [ "aarch64-linux" ];
      maxJobs = 8;
    })
    (mkBuilder {
      hostName = "gkr";
      systems = [ "aarch64-darwin" ];
      maxJobs = 8;
    })
  ];

  hostNames = map (builder: builder.hostName) builders;
  sshConfigs = lib.concatMapStrings mkSshConfig hostNames;
in
{
  nix = {
    settings.trusted-users = [ "nix-ssh" ];
    distributedBuilds = true;
    buildMachines = builders;
  };

  programs.ssh.extraConfig = sshConfigs;
}
