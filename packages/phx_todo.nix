{
  pkgs,
  ...
}:
let
  src = pkgs.fetchFromGitHub {
    owner = "multivac61";
    repo = "phx_todo";
    rev = "df490ec4f979c0df5e663b1788f87318c92c76f1";
    hash = "sha256-fCk7jpUKFtDBd6Md47Jwh4pJE+bwHCFDtua5H6c3Q2U=";
  };
  pname = "phx_todo";
  version = "0.1.0";
in
pkgs.beamPackages.mixRelease {
  inherit pname version src;

  mixFodDeps = pkgs.beamPackages.fetchMixDeps {
    inherit version src pname;
    sha256 = "sha256-JYfNRnMsBxmGReB/RBzeKH7DPR90cBU0vcZpvz7C7c8=";
  };

  preConfigure = ''
    substituteInPlace config/config.exs \
      --replace "config :tailwind," "config :tailwind, path: \"${pkgs.tailwindcss}/bin/tailwindcss\","\
      --replace "config :esbuild," "config :esbuild, path: \"${pkgs.esbuild}/bin/esbuild\", "
  '';

  preBuild = ''
    # for external task you need a workaround for the no deps check flag
    # https://github.com/phoenixframework/phoenix/issues/2690
    mix do deps.loadpaths --no-deps-check, assets.deploy
    mix do deps.loadpaths --no-deps-check, phx.gen.release

    # Ensure that `tzdata` doesn't write into its store-path
    cat >> config/runtime.exs <<EOF
    config :tzdata, :data_dir, System.get_env("TZDATA_DIR")
    EOF
  '';
}
