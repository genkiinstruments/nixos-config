{ inputs, config, ... }:
{
  imports = [
    inputs.comin.darwinModules.comin
    inputs.agenix.nixosModules.default
  ];

  age.secrets.buildbot-github-token.file = "${inputs.secrets}/buildbot-github-token.age";

  services.comin = {
    enable = true;
    remotes = [
      {
        name = "origin";
        url = "https://github.com/genkiinstruments/nixos-config";
        branches.main.name = "main";
        auth.access_token_path = config.age.secrets.buildbot-github-token.path;
      }
    ];
  };
}
