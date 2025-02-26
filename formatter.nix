{
  pkgs,
  inputs,
  ...
}:
inputs.treefmt-nix.lib.mkWrapper pkgs {
  projectRootFile = "flake.nix";
  programs.deadnix.enable = true;
  programs.stylua.enable = true;
  programs.clang-format.enable = true;
  programs.deno.enable = true;
  programs.nixfmt.enable = true;
  programs.shellcheck.enable = true;
  programs.taplo.enable = true;

  programs.shfmt.enable = true;
  settings.formatter.shfmt.includes = [
    "*.envrc"
    "*.envrc.private-template"
    "*.bashrc"
    "*.bash_profile"
    "*.bashrc.load"
  ];

  settings.global.excludes = [
    "*.png"
    "*.jpg"
    "*.zip"
    "*.touchosc"
    "*.pdf"
    "*.svg"
    "*.ico"
    "*.webp"
    "*.gif"
    "**/lazyvim.json"
    "**/lazy-lock.json"
  ];
}
