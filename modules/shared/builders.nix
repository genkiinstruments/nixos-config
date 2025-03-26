_: {
  nix = {
    settings.trusted-users = [ "nix-ssh" ];
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "gdrn";
        sshUser = "nix-ssh";
        protocol = "ssh-ng";
        systems = [ "x86_64-linux" ];
        maxJobs = 32;
        supportedFeatures = [
          "nixos-test"
          "benchmark"
          "big-parallel"
          "kvm"
        ];
      }
      {
        hostName = "x";
        sshUser = "nix-ssh";
        protocol = "ssh-ng";
        systems = [ "x86_64-linux" ];
        maxJobs = 32;
        supportedFeatures = [
          "nixos-test"
          "benchmark"
          "big-parallel"
          "kvm"
        ];
      }
      {
        hostName = "v1";
        sshUser = "nix-ssh";
        protocol = "ssh-ng";
        systems = [
          "aarch64-linux"
        ];
        maxJobs = 14;
        supportedFeatures = [
          "nixos-test"
          "benchmark"
          "big-parallel"
          "kvm"
        ];
      }
      {
        hostName = "gkr";
        sshUser = "nix-ssh";
        protocol = "ssh-ng";
        systems = [ "aarch64-darwin" ];
        maxJobs = 8;
        supportedFeatures = [
          "benchmark"
          "big-parallel"
        ];
      }
    ];
  };
  programs.ssh.extraConfig = ''
    Host gdrn gdrn.tail01dbd.ts.net
      User nix-ssh
      HostName gdrn.tail01dbd.ts.net
      StrictHostKeyChecking accept-new
      BatchMode yes
      PubkeyAuthentication yes
      IdentitiesOnly yes
      
    Host v1 v1.tail01dbd.ts.net
      User nix-ssh
      HostName v1.tail01dbd.ts.net
      StrictHostKeyChecking accept-new
      BatchMode yes
      PubkeyAuthentication yes
      IdentitiesOnly yes

    Host x x.tail01dbd.ts.net
      User nix-ssh
      HostName x.tail01dbd.ts.net
      StrictHostKeyChecking accept-new
      BatchMode yes
      PubkeyAuthentication yes
      IdentitiesOnly yes
      
    Host gkr gkr.tail01dbd.ts.net
      User nix-ssh
      HostName gkr.tail01dbd.ts.net
      StrictHostKeyChecking accept-new
      BatchMode yes
      PubkeyAuthentication yes
      IdentitiesOnly yes
  '';
}
