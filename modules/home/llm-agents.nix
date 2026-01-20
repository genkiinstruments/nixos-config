{
  perSystem,
  pkgs,
  ...
}:
{
  home.packages = with perSystem.llm-agents; [
    claude-code
    pkgs.claude-code-acp # for some reason the llm-agents stuff is broken
  ];

  nix.settings.substituters = [ "https://claude-code.cachix.org" ];
  nix.settings.trusted-public-keys = [
    "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
  ];
}
