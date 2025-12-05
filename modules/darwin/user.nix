{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.genki.user;
in
{
  options.genki.user = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    description = "Primary user name for this Darwin system";
  };

  config = lib.mkIf (cfg != null) {
    system.primaryUser = cfg;
    users.knownUsers = [ cfg ];
    users.users.${cfg} = {
      uid = 501;
      isHidden = false;
      home = "/Users/${cfg}";
      shell = pkgs.fish;
    };
    nix.settings.trusted-users = [ cfg ];
  };
}
