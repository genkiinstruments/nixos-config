{
  lib,
  config,
  ...
}:
let
  cfg = config.genki.builders;

  mkBuilder =
    {
      hostName,
      system,
      maxJobs,
      sshUser ? cfg.sshUser,
      supportedFeatures ? cfg.defaultSupportedFeatures,
    }:
    {
      inherit
        hostName
        maxJobs
        sshUser
        supportedFeatures
        ;
      systems = [ system ];
      protocol = "ssh-ng";
    };

  mkSshConfig =
    { hostName }:
    ''
      Host ${hostName} ${hostName}.${cfg.tailnetDomain}
        User ${cfg.sshUser}
        HostName ${hostName}.${cfg.tailnetDomain}
        StrictHostKeyChecking accept-new
        BatchMode yes
        PubkeyAuthentication yes
        IdentitiesOnly yes
    '';

  processedBuilders = map mkBuilder cfg.builders;
  sshConfigs = lib.concatMapStrings (
    builder: mkSshConfig { inherit (builder) hostName; }
  ) processedBuilders;
in
{
  options.genki.builders = {
    enable = lib.mkEnableOption "distributed builders" // {
      default = true;
    };

    builders = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            hostName = lib.mkOption {
              type = lib.types.str;
              description = "Hostname of the builder";
            };
            system = lib.mkOption {
              type = lib.types.str;
              description = "System architecture (e.g., x86_64-linux, aarch64-darwin)";
            };
            maxJobs = lib.mkOption {
              type = lib.types.int;
              description = "Maximum number of concurrent jobs";
            };
            sshUser = lib.mkOption {
              type = lib.types.str;
              default = cfg.sshUser;
              description = "SSH user for the builder";
            };
            supportedFeatures = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = cfg.defaultSupportedFeatures;
              description = "Supported features of the builder";
            };
          };
        }
      );
      default = [
        {
          hostName = "m2";
          system = "aarch64-linux";
          maxJobs = 15;
        }
        {
          hostName = "gdrn";
          system = "x86_64-linux";
          maxJobs = 13;
        }
        {
          hostName = "x";
          system = "x86_64-linux";
          maxJobs = 23;
        }
        {
          hostName = "pbt";
          system = "aarch64-linux";
          maxJobs = 3;
        }
        {
          hostName = "gkr";
          system = "aarch64-darwin";
          maxJobs = 3;
        }
      ];
      description = "List of distributed builders";
    };

    sshUser = lib.mkOption {
      type = lib.types.str;
      default = "nix-ssh";
      description = "Default SSH user for builders";
    };

    tailnetDomain = lib.mkOption {
      type = lib.types.str;
      default = "tail01dbd.ts.net";
      description = "Tailscale domain for builders";
    };

    defaultSupportedFeatures = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];
      description = "Default supported features for builders";
    };
  };

  config = lib.mkIf cfg.enable {
    nix.distributedBuilds = true;
    nix.settings.trusted-users = [ cfg.sshUser ];
    nix.buildMachines = processedBuilders;

    programs.ssh.extraConfig = sshConfigs;
  };
}
