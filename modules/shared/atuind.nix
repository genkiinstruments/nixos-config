{ pkgs, ... }: {
  systemd.user.services.atuind = {
    enable = true;

    environment = {
      ATUIN_LOG = "info";
    };
    serviceConfig = {
      ExecStart = "${pkgs.atuin}/bin/atuin daemon";
    };
    after = [ "network.target" ];
    wantedBy = [ "default.target" ];
  };

  programs.atuin.settings.daemon.enabled = true; # https://github.com/atuinsh/atuin/issues/952#issuecomment-2199964530
}
