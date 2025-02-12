{
  inputs,
  perSystem,
  pkgs,
  ...
}:
{
  imports = [ inputs.self.homeModules.default ];
  home.activation.setup-mvim = ''${perSystem.self.setup-mvim}/bin/setup-mvim'';

  # This enables running unpatched binaries from Nix store which is necessary for Mason (nvim) to work see also the environment variable NIX_LD below
  # Detailed explanation: http://archive.today/WFxH7
  programs.fish.interactiveShellInit = ''
    export NIX_LD=$(nix eval --extra-experimental-features nix-command --impure --raw --expr 'let pkgs = import <nixpkgs> {}; NIX_LD = pkgs.lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker"; in NIX_LD')
  '';
  programs.ssh = {
    controlMaster = "auto";
    controlPath = "/tmp/ssh-%u-%r@%h:%p";
    controlPersist = "1800";
    forwardAgent = true;
    addKeysToAgent = "yes";
    serverAliveInterval = 900;
    extraConfig = "SetEnv TERM=xterm-256color";
  };
}
