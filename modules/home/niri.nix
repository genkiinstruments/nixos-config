{
  config,
  ...
}:
{
  programs.niri.settings = {
    # Prefer server-side decorations
    prefer-no-csd = true;

    # Screenshot path
    screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

    # GPD Pocket 4 display configuration
    outputs."eDP-1" = {
      scale = 1.5;
      # Uncomment if you need rotation
      # transform.rotation = 90;
    };

    # Input configuration
    input = {
      keyboard.xkb = {
        layout = "us";
      };

      touchpad = {
        tap = true;
        dwt = true; # disable while typing
        natural-scroll = true;
        accel-speed = 0.2;
      };

      mouse = {
        accel-profile = "flat";
        natural-scroll = true;
      };

      focus-follows-mouse = {
        enable = true;
        max-scroll-amount = "0%";
      };
    };

    # Layout configuration
    layout = {
      gaps = 12;
      center-focused-column = "never";

      preset-column-widths = [
        { proportion = 1.0 / 3.0; }
        { proportion = 1.0 / 2.0; }
        { proportion = 2.0 / 3.0; }
      ];

      default-column-width = {
        proportion = 1.0 / 2.0;
      };

      focus-ring = {
        width = 2;
        active.color = "#7fc8ff";
        inactive.color = "#505050";
      };

      shadow = {
        enable = true;
        softness = 30;
        color = "#0007";
      };
    };

    # Programs to start with niri
    spawn-at-startup = [
      { command = [ "waybar" ]; }
      { command = [ "mako" ]; }
      # Uncomment to set a wallpaper
      # { command = [ "swaybg" "-i" "/path/to/wallpaper.png" "-m" "fill" ]; }
    ];

    # Window rules
    window-rules = [
      {
        matches = [ { app-id = "^org\\.gnome\\."; } ];
        draw-border-with-background = false;
      }
      {
        matches = [
          { app-id = "^pavucontrol$"; }
          { app-id = "^nm-connection-editor$"; }
          { app-id = "^polkit-gnome-authentication-agent-1$"; }
        ];
        open-floating = true;
      }
    ];

    # Keybindings
    binds =
      with config.lib.niri.actions;
      let
        mod = "Mod";
        # Hyper = Caps Lock held (via keyd: Ctrl+Alt+Shift+Super)
        hyper = "Ctrl+Alt+Shift+Super";
      in
      {
        # ============================================
        # Hyper key bindings (Caps Lock held + key)
        # ============================================
        "${hyper}+T".action = spawn "ghostty";
        "${hyper}+B".action = spawn "firefox";
        "${hyper}+D".action = spawn "fuzzel";
        "${hyper}+Q".action = close-window;
        "${hyper}+F".action = maximize-column;
        "${hyper}+O".action = toggle-overview;

        # Hyper + vim navigation
        "${hyper}+H".action = focus-column-left;
        "${hyper}+J".action = focus-window-down;
        "${hyper}+K".action = focus-window-up;
        "${hyper}+L".action = focus-column-right;

        # Hyper + shift + vim to move windows
        "${hyper}+Shift+H".action = move-column-left;
        "${hyper}+Shift+J".action = move-window-down;
        "${hyper}+Shift+K".action = move-window-up;
        "${hyper}+Shift+L".action = move-column-right;

        # Hyper + number for workspaces
        "${hyper}+1".action = focus-workspace 1;
        "${hyper}+2".action = focus-workspace 2;
        "${hyper}+3".action = focus-workspace 3;
        "${hyper}+4".action = focus-workspace 4;
        "${hyper}+5".action = focus-workspace 5;

        # ============================================
        # Regular Mod (Super) bindings as fallback
        # ============================================
        "${mod}+Return".action = spawn "ghostty";
        "${mod}+D".action = spawn "fuzzel";
        "${mod}+Shift+Q".action = close-window;
        "${mod}+F".action = maximize-column;
        "${mod}+Shift+F".action = fullscreen-window;
        "${mod}+V".action = toggle-window-floating;
        "${mod}+O".action = toggle-overview;

        # Mod + vim navigation
        "${mod}+H".action = focus-column-left;
        "${mod}+J".action = focus-window-down;
        "${mod}+K".action = focus-window-up;
        "${mod}+L".action = focus-column-right;

        # Mod + arrow keys
        "${mod}+Left".action = focus-column-left;
        "${mod}+Down".action = focus-window-down;
        "${mod}+Up".action = focus-window-up;
        "${mod}+Right".action = focus-column-right;

        # Move windows
        "${mod}+Shift+H".action = move-column-left;
        "${mod}+Shift+J".action = move-window-down;
        "${mod}+Shift+K".action = move-window-up;
        "${mod}+Shift+L".action = move-column-right;

        "${mod}+Shift+Left".action = move-column-left;
        "${mod}+Shift+Right".action = move-column-right;

        # Workspaces
        "${mod}+1".action = focus-workspace 1;
        "${mod}+2".action = focus-workspace 2;
        "${mod}+3".action = focus-workspace 3;
        "${mod}+4".action = focus-workspace 4;
        "${mod}+5".action = focus-workspace 5;
        "${mod}+6".action = focus-workspace 6;
        "${mod}+7".action = focus-workspace 7;
        "${mod}+8".action = focus-workspace 8;
        "${mod}+9".action = focus-workspace 9;

        "${mod}+Ctrl+1".action.move-column-to-workspace = [ 1 ];
        "${mod}+Ctrl+2".action.move-column-to-workspace = [ 2 ];
        "${mod}+Ctrl+3".action.move-column-to-workspace = [ 3 ];
        "${mod}+Ctrl+4".action.move-column-to-workspace = [ 4 ];
        "${mod}+Ctrl+5".action.move-column-to-workspace = [ 5 ];

        "${mod}+Page_Down".action = focus-workspace-down;
        "${mod}+Page_Up".action = focus-workspace-up;

        # Scroll to switch workspaces
        "${mod}+WheelScrollDown" = {
          action = focus-workspace-down;
          cooldown-ms = 150;
        };
        "${mod}+WheelScrollUp" = {
          action = focus-workspace-up;
          cooldown-ms = 150;
        };

        # Column width
        "${mod}+R".action = switch-preset-column-width;
        "${mod}+Minus".action = set-column-width "-10%";
        "${mod}+Equal".action = set-column-width "+10%";

        # Screenshots (use grimblast or similar via spawn if needed)
        # "Print".action = spawn "grimblast" "copy" "area";

        # Media keys (work even when locked)
        "XF86AudioRaiseVolume" = {
          action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.05+";
          allow-when-locked = true;
        };
        "XF86AudioLowerVolume" = {
          action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.05-";
          allow-when-locked = true;
        };
        "XF86AudioMute" = {
          action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";
          allow-when-locked = true;
        };

        "XF86MonBrightnessUp".action = spawn "brightnessctl" "set" "+5%";
        "XF86MonBrightnessDown".action = spawn "brightnessctl" "set" "5%-";

        "XF86AudioPlay".action = spawn "playerctl" "play-pause";
        "XF86AudioNext".action = spawn "playerctl" "next";
        "XF86AudioPrev".action = spawn "playerctl" "previous";

        # System
        "${mod}+Shift+E".action = quit;
        "${mod}+Shift+P".action = power-off-monitors;
      };
  };
}
