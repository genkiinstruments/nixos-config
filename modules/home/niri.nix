{ ... }:
{
  # GTK settings - font size 12
  gtk = {
    enable = true;
    font = {
      name = "Noto Sans";
      size = 12;
    };
  };

  # dconf settings for GNOME apps
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      font-name = "Noto Sans 12";
      monospace-font-name = "JetBrainsMono Nerd Font Mono 12";
    };
  };

  # Mako notifications - catppuccin mocha
  xdg.configFile."mako/config".text = ''
    background-color=#1e1e2e
    text-color=#cdd6f4
    border-color=#cba6f7
    border-radius=4
    border-size=1
    padding=10
    default-timeout=5000
  '';

  # Walker launcher - catppuccin mocha
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

    [clipboard]
    max_entries = 100

    [activation_mode]
    disabled = false
    use_f_keys = false
    use_alt = true

    [modules]
    applications.enabled = true
    applications.priority = 1
    calc.enabled = true
    calc.priority = 0
    clipboard.enabled = true
    clipboard.priority = 2
    commands.enabled = true
    commands.priority = 3
    websearch.enabled = true
    websearch.priority = 4
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
      scale 1.5
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

      // Catppuccin Mocha focus indicator
      focus-ring {
        width 1
        active-color "#cba6f7"  // mauve
        inactive-color "#1e1e2e"  // base
      }

      // No border for cleaner look
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
      Ctrl+Alt+Super+G { spawn "ghostty" "-e" "lazygit"; }
      Ctrl+Alt+Super+D { spawn "walker"; }
      Ctrl+Alt+Super+C { spawn "walker" "-m" "clipboard"; }
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

      // Hyper + P for screenshot
      Ctrl+Alt+Super+P { screenshot; }

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
      Ctrl+Alt+Super+Shift+P { power-off-monitors; }
    }
  '';
}
