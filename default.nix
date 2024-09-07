{
  lib,
  stdenv,
  fetchFromGitHub,
  pkgs,
}:

stdenv.mkDerivation {
  pname = "fireplace";
  version = "unstable-2020-02-02";

  buildInputs = with pkgs; [
    ncurses
    gcc
  ];

  installPhase = ''
    mkdir -p $out/bin
    install fireplace $out/bin/
  '';

  src = fetchFromGitHub {
    owner = "Wyatt915";
    repo = "fireplace";
    rev = "aa2070b73be9fb177007fc967b066d88a37e3408";
    hash = "sha256-2NUE/zaFoGwkZxgvVCYXxToiL23aVUFwFNlQzEq9GEc=";
  };

  meta = {
    description = "A cozy fireplace in your terminal";
    homepage = "https://github.com/Wyatt915/fireplace";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ multivac61 ];
    mainProgram = "fireplace";
    platforms = lib.platforms.all;
  };
}
