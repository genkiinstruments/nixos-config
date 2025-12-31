{ lib, ... }:
{
  # Override ghostty for Linux: use super instead of cmd, hide window decorations
  home.file.".config/ghostty/config".text = lib.mkForce (
    ''
      # Linux-specific: hide window decorations (tabs via tmux)
      window-decoration = false
      gtk-titlebar = false

    ''
    + builtins.replaceStrings [ "cmd+" ] [ "super+" ] (builtins.readFile ./config/ghostty/config)
  );

  # Disable stylix for ghostty (we manage it manually)
  stylix.targets.ghostty.enable = false;

  # Mako notifications - styled by stylix
  services.mako = {
    enable = true;
    borderRadius = 4;
    borderSize = 1;
    padding = "10";
    defaultTimeout = 5000;
  };

  # Walker launcher - manual catppuccin mocha (stylix doesn't support walker)
  xdg.configFile."walker/config.toml".text = ''
    placeholder = "Search..."
    show_initial_entries = true
    ssh_host_file = ""
    terminal = "ghostty"
    ignore_mouse = false

    [search]
    delay = 0
    hide_icons = false
    margin_spinner = 10
    hide_spinner = false

    [keys]
    next = ["Down", "ctrl j", "ctrl n"]
    prev = ["Up", "ctrl k", "ctrl p"]

    [keybinds]
    close = ["Escape"]

    [activation_mode]
    disabled = false
    use_f_keys = false
    use_alt = true

    [providers]
    default = ["desktopapplications", "commands"]
    empty = ["desktopapplications"]

    [providers.clipboard]
    time_format = "%H:%M"

    [[providers.prefixes]]
    prefix = ":"
    provider = "clipboard"

    [[providers.prefixes]]
    prefix = "="
    provider = "calc"

    [providers.actions]
    commands = [
      { action = "run", label = "run", default = true, bind = "Return" }
    ]

    [[providers.custom]]
    name = "commands"

    [[providers.custom.entries]]
    label = "Logout"
    exec = "sh -c 'niri msg action quit'"

    [[providers.custom.entries]]
    label = "Power Off"
    exec = "systemctl poweroff"

    [[providers.custom.entries]]
    label = "Reboot"
    exec = "systemctl reboot"
  '';

  xdg.configFile."walker/style.css".text = ''
    * {
      font-family: "JetBrainsMono Nerd Font Mono";
      font-size: 12pt;
    }

    #window {
      background: transparent;
    }

    #box {
      background: #1e1e2e;
      border: 1px solid #cba6f7;
      border-radius: 8px;
      padding: 8px;
    }

    #search {
      background: #313244;
      color: #cdd6f4;
      border: none;
      border-radius: 4px;
      padding: 8px 12px;
      margin-bottom: 8px;
    }

    #search:focus {
      outline: none;
    }

    #list {
      background: transparent;
    }

    row {
      padding: 4px 8px;
      border-radius: 4px;
    }

    row:selected {
      background: #313244;
    }

    row:hover {
      background: #45475a;
    }

    #icon {
      margin-right: 8px;
    }

    #label {
      color: #cdd6f4;
    }

    #sub {
      color: #a6adc8;
      font-size: 12px;
    }

    .activationlabel {
      color: #cba6f7;
      font-size: 12px;
    }
  '';

  xdg.configFile."niri/config.kdl".text = ''
    // GPD Pocket 4 display configuration
    output "eDP-1" {
      scale 1.0
    }

    output "DP-1" {
      scale 1.0
    }

    input {
      keyboard {
        xkb {
          layout "us"
        }
      }

      touchpad {
        tap
        dwt
        natural-scroll
        accel-speed 0.2
      }

      mouse {
        accel-profile "flat"
        natural-scroll
      }

      focus-follows-mouse max-scroll-amount="0%"
    }

    // Layout configuration - zero gaps, maximum screen use
    layout {
      gaps 0
      center-focused-column "never"

      preset-column-widths {
        proportion 0.33333
        proportion 0.5
        proportion 0.66667
        proportion 1.0
      }

      default-column-width { proportion 0.5; }

      focus-ring {
        off
      }

      border {
        off
      }

      // Disable shadows for flat look
      shadow {
        off
      }
    }

    // Prefer server-side decorations
    prefer-no-csd

    screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

    // Programs to start with niri
    spawn-at-startup "mako"
    spawn-at-startup "swaybg" "-c" "#000000"  // pure black for contrast
    spawn-at-startup "wl-paste" "--watch" "cliphist" "store"  // clipboard history

    // Window rules

    // Dim unfocused windows
    window-rule {
      match is-focused=false
      opacity 0.8
    }

    window-rule {
      match app-id=r#"^org\.gnome\."#
      draw-border-with-background false
    }

    window-rule {
      match app-id="^pavucontrol$"
      match app-id="^nm-connection-editor$"
      open-floating true
    }

    binds {
      // Hyper key bindings (Caps Lock via keyd = Ctrl+Alt+Super)
      Ctrl+Alt+Super+Return { spawn "ghostty"; }
      Ctrl+Alt+Super+T { spawn "ghostty"; }
      Ctrl+Alt+Super+B { spawn "firefox"; }
      Ctrl+Alt+Super+S { spawn "signal-desktop"; }
      Ctrl+Alt+Super+D { spawn "walker"; }
      Ctrl+Alt+Super+C { spawn "ghostty" "-e" "sh" "-c" "cliphist list | fzf --no-info --reverse | cliphist decode | wl-copy"; }
      Ctrl+Alt+Super+Q { close-window; }
      Ctrl+Alt+Super+F { maximize-column; }
      Ctrl+Alt+Super+Shift+F { fullscreen-window; }
      Ctrl+Alt+Super+V { toggle-window-floating; }
      Ctrl+Alt+Super+O { toggle-overview; }

      // Hyper + vim navigation
      Ctrl+Alt+Super+H { focus-column-left; }
      Ctrl+Alt+Super+J { focus-window-down; }
      Ctrl+Alt+Super+K { focus-window-up; }
      Ctrl+Alt+Super+L { focus-column-right; }

      // Hyper + arrow keys
      Ctrl+Alt+Super+Left { focus-column-left; }
      Ctrl+Alt+Super+Down { focus-window-down; }
      Ctrl+Alt+Super+Up { focus-window-up; }
      Ctrl+Alt+Super+Right { focus-column-right; }

      // Hyper + Shift + vim to move windows
      Ctrl+Alt+Super+Shift+H { move-column-left; }
      Ctrl+Alt+Super+Shift+J { move-window-down; }
      Ctrl+Alt+Super+Shift+K { move-window-up; }
      Ctrl+Alt+Super+Shift+L { move-column-right; }

      Ctrl+Alt+Super+Shift+Left { move-column-left; }
      Ctrl+Alt+Super+Shift+Right { move-column-right; }

      // Hyper + number for workspaces
      Ctrl+Alt+Super+1 { focus-workspace 1; }
      Ctrl+Alt+Super+2 { focus-workspace 2; }
      Ctrl+Alt+Super+3 { focus-workspace 3; }
      Ctrl+Alt+Super+4 { focus-workspace 4; }
      Ctrl+Alt+Super+5 { focus-workspace 5; }
      Ctrl+Alt+Super+6 { focus-workspace 6; }
      Ctrl+Alt+Super+7 { focus-workspace 7; }
      Ctrl+Alt+Super+8 { focus-workspace 8; }
      Ctrl+Alt+Super+9 { focus-workspace 9; }

      // Hyper + Shift + number to move window to workspace
      Ctrl+Alt+Super+Shift+1 { move-column-to-workspace 1; }
      Ctrl+Alt+Super+Shift+2 { move-column-to-workspace 2; }
      Ctrl+Alt+Super+Shift+3 { move-column-to-workspace 3; }
      Ctrl+Alt+Super+Shift+4 { move-column-to-workspace 4; }
      Ctrl+Alt+Super+Shift+5 { move-column-to-workspace 5; }

      Ctrl+Alt+Super+Page_Down { focus-workspace-down; }
      Ctrl+Alt+Super+Page_Up { focus-workspace-up; }

      // Scroll to switch workspaces
      Ctrl+Alt+Super+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }
      Ctrl+Alt+Super+WheelScrollUp cooldown-ms=150 { focus-workspace-up; }

      // Column width
      Ctrl+Alt+Super+R { switch-preset-column-width; }
      Ctrl+Alt+Super+Minus { set-column-width "-10%"; }
      Ctrl+Alt+Super+Equal { set-column-width "+10%"; }

      // Hyper + Tab to cycle monitors
      Ctrl+Alt+Super+Tab { focus-monitor-next; }
      Ctrl+Alt+Super+Shift+Tab { move-column-to-monitor-next; }

      // Hyper + ? to show keybindings
      Ctrl+Alt+Super+Shift+Slash { show-hotkey-overlay; }

      // Hyper + P for fullscreen screenshot, Hyper + Shift + P for region
      Ctrl+Alt+Super+P { screenshot-screen; }
      Ctrl+Alt+Super+Shift+P { screenshot; }

      // Media keys (work even when locked)
      XF86AudioRaiseVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.05+"; }
      XF86AudioLowerVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.05-"; }
      XF86AudioMute allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }

      XF86MonBrightnessUp { spawn "brightnessctl" "set" "+5%"; }
      XF86MonBrightnessDown { spawn "brightnessctl" "set" "5%-"; }

      XF86AudioPlay { spawn "playerctl" "play-pause"; }
      XF86AudioNext { spawn "playerctl" "next"; }
      XF86AudioPrev { spawn "playerctl" "previous"; }

      // System
      Ctrl+Alt+Super+Shift+E { quit; }
      Ctrl+Alt+Super+Shift+O { power-off-monitors; }
    }
  '';
}
