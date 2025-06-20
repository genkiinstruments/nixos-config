{
  pkgs,
  flake,
  lib ? pkgs.lib,
}:
let
  mvimBase = flake.lib.mvim-base { inherit flake pkgs lib; };

  name = "mvim";
in
pkgs.writeShellApplication {
  inherit name;
  text = ''
    unset VIMINIT
    export PATH="${mvimBase.commonEnvVars.PATH}:$PATH"
    export NVIM_APPNAME="${mvimBase.commonEnvVars.NVIM_APPNAME}"

    ${mvimBase.setupConfigScript "$XDG_CONFIG_HOME/$NVIM_APPNAME"}

    exec nvim "$@"
  '';

  meta = {
    description = "Standalone mvim with configuration stored in nix store";
    mainProgram = name;
  };
}
