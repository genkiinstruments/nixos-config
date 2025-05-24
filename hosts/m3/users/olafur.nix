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

  # Configure SSH for clipboard sharing
  programs.ssh = {
    controlMaster = "auto";
    controlPath = "/tmp/ssh-%u-%r@%h:%p";
    controlPersist = "1800";
    forwardAgent = true;
    addKeysToAgent = "yes";
    serverAliveInterval = 900;
    enable = true;
  };
  programs.fish.interactiveShellInit = ''
    #-------------------------------------------------------------------------------
    # SSH Agent
    #-------------------------------------------------------------------------------
    # Set SSH_ENV variable if not already set
    if test -z "$SSH_ENV"
        set -xg SSH_ENV $HOME/.ssh/environment
    end

    # Create .ssh directory if it doesn't exist
    if not test -d $HOME/.ssh
        mkdir -p $HOME/.ssh
        chmod 0700 $HOME/.ssh
    end

    # More reliable ssh-agent detection function
    function __ssh_agent_is_started -d "check if ssh agent is already started"
        # First, try to use the environment file if it exists
        if test -f $SSH_ENV
            source $SSH_ENV >/dev/null
        end
        
        # Check if SSH_AGENT_PID is set and if the process is running
        if test -n "$SSH_AGENT_PID" -a -n "$SSH_AUTH_SOCK"
            ps -p $SSH_AGENT_PID >/dev/null
            if test $status -eq 0
                # Agent process exists, test the connection
                ${pkgs.openssh}/bin/ssh-add -l >/dev/null 2>&1
                set -l add_status $status
                if test $add_status -eq 0 -o $add_status -eq 1
                    # Agent is working (has keys or no keys but is running)
                    return 0
                end
            end
        end
        
        # If we get here, either SSH_AGENT_PID wasn't set, process isn't running, 
        # or the connection test failed
        return 1
    end

    function __ssh_agent_start -d "start a new ssh agent"
        # Kill any existing ssh-agent processes
        if test -n "$SSH_AGENT_PID"
            echo "Stopping existing ssh-agent (PID: $SSH_AGENT_PID)"
            kill $SSH_AGENT_PID >/dev/null 2>&1
        end
        
        echo "Starting new ssh-agent"
        ${pkgs.openssh}/bin/ssh-agent -c | sed 's/^echo/#echo/' >$SSH_ENV
        chmod 600 $SSH_ENV
        source $SSH_ENV >/dev/null
        ${pkgs.openssh}/bin/ssh-add
    end

    # Only start ssh-agent if one isn't already running
    if not __ssh_agent_is_started
        __ssh_agent_start
    end

    function lg
      set -x LAZYGIT_NEW_DIR_FILE ~/.lazygit/newdir

      lazygit $argv

      if test -f $LAZYGIT_NEW_DIR_FILE
          cd (cat $LAZYGIT_NEW_DIR_FILE)
          rm -f $LAZYGIT_NEW_DIR_FILE > /dev/null
      end
    end
  '';
}
