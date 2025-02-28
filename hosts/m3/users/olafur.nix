{
  flake,
  pkgs,
  ...
}:
{
  imports = [
    flake.homeModules.default
    flake.homeModules.nvim
  ];
  programs.ssh = {
    matchBlocks = {
      "github.com" = {
        user = "git";
        identityFile = "~/.ssh/id_ed25519_sk";
        identitiesOnly = true;
      };
    };
    controlMaster = "auto";
    controlPath = "/tmp/ssh-%u-%r@%h:%p";
    controlPersist = "1800";
    forwardAgent = true;
    addKeysToAgent = "yes";
    serverAliveInterval = 900;
    extraConfig = "SetEnv TERM=xterm-256color";
  };
  programs.fish.interactiveShellInit = ''
    #-------------------------------------------------------------------------------
    # SSH Agent
    #-------------------------------------------------------------------------------
    function __ssh_agent_is_started -d "check if ssh agent is already started"
        if begin
                test -f $SSH_ENV; and test -z "$SSH_AGENT_PID"
            end
            source $SSH_ENV >/dev/null
        end

        if test -z "$SSH_AGENT_PID"
            return 1
        end

        ${pkgs.openssh}/bin/ssh-add -l >/dev/null 2>&1
        if test $status -eq 2
            return 1
        end
    end

    function __ssh_agent_start -d "start a new ssh agent"
        ${pkgs.openssh}/bin/ssh-agent -c | sed 's/^echo/#echo/' >$SSH_ENV
        chmod 600 $SSH_ENV
        source $SSH_ENV >/dev/null
        ${pkgs.openssh}/bin/ssh-add
    end

    if not test -d $HOME/.ssh
        mkdir -p $HOME/.ssh
        chmod 0700 $HOME/.ssh
    end

    if test -z "$SSH_ENV"
        set -xg SSH_ENV $HOME/.ssh/environment
    end

    if not __ssh_agent_is_started
        __ssh_agent_start
    end
  '';

}
