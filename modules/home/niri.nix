{ ... }:
{
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

    // Layout configuration
    layout {
      gaps 12
      center-focused-column "never"

      preset-column-widths {
        proportion 0.33333
        proportion 0.5
        proportion 0.66667
      }

      default-column-width { proportion 0.5; }

      focus-ring {
        width 2
        active-color "#7fc8ff"
        inactive-color "#505050"
      }

      shadow {
        on
        softness 30
        color "#00000070"
      }
    }

    // Prefer server-side decorations
    prefer-no-csd

    screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

    // Programs to start with niri
    spawn-at-startup "waybar"
    spawn-at-startup "mako"

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
      // Hyper key bindings (Caps Lock held via keyd = Ctrl+Alt+Shift+Super)
      Ctrl+Alt+Shift+Super+T { spawn "ghostty"; }
      Ctrl+Alt+Shift+Super+B { spawn "firefox"; }
      Ctrl+Alt+Shift+Super+D { spawn "fuzzel"; }
      Ctrl+Alt+Shift+Super+Q { close-window; }
      Ctrl+Alt+Shift+Super+F { maximize-column; }
      Ctrl+Alt+Shift+Super+O { toggle-overview; }

      // Hyper + vim navigation
      Ctrl+Alt+Shift+Super+H { focus-column-left; }
      Ctrl+Alt+Shift+Super+J { focus-window-down; }
      Ctrl+Alt+Shift+Super+K { focus-window-up; }
      Ctrl+Alt+Shift+Super+L { focus-column-right; }

      // Hyper + shift + vim to move windows
      Ctrl+Alt+Shift+Super+Shift+H { move-column-left; }
      Ctrl+Alt+Shift+Super+Shift+J { move-window-down; }
      Ctrl+Alt+Shift+Super+Shift+K { move-window-up; }
      Ctrl+Alt+Shift+Super+Shift+L { move-column-right; }

      // Hyper + number for workspaces
      Ctrl+Alt+Shift+Super+1 { focus-workspace 1; }
      Ctrl+Alt+Shift+Super+2 { focus-workspace 2; }
      Ctrl+Alt+Shift+Super+3 { focus-workspace 3; }
      Ctrl+Alt+Shift+Super+4 { focus-workspace 4; }
      Ctrl+Alt+Shift+Super+5 { focus-workspace 5; }

      // Regular Mod (Super) bindings
      Mod+Return { spawn "ghostty"; }
      Mod+D { spawn "fuzzel"; }
      Mod+Shift+Q { close-window; }
      Mod+F { maximize-column; }
      Mod+Shift+F { fullscreen-window; }
      Mod+V { toggle-window-floating; }
      Mod+O { toggle-overview; }

      // Mod + vim navigation
      Mod+H { focus-column-left; }
      Mod+J { focus-window-down; }
      Mod+K { focus-window-up; }
      Mod+L { focus-column-right; }

      // Mod + arrow keys
      Mod+Left { focus-column-left; }
      Mod+Down { focus-window-down; }
      Mod+Up { focus-window-up; }
      Mod+Right { focus-column-right; }

      // Move windows
      Mod+Shift+H { move-column-left; }
      Mod+Shift+J { move-window-down; }
      Mod+Shift+K { move-window-up; }
      Mod+Shift+L { move-column-right; }

      Mod+Shift+Left { move-column-left; }
      Mod+Shift+Right { move-column-right; }

      // Workspaces
      Mod+1 { focus-workspace 1; }
      Mod+2 { focus-workspace 2; }
      Mod+3 { focus-workspace 3; }
      Mod+4 { focus-workspace 4; }
      Mod+5 { focus-workspace 5; }
      Mod+6 { focus-workspace 6; }
      Mod+7 { focus-workspace 7; }
      Mod+8 { focus-workspace 8; }
      Mod+9 { focus-workspace 9; }

      Mod+Ctrl+1 { move-column-to-workspace 1; }
      Mod+Ctrl+2 { move-column-to-workspace 2; }
      Mod+Ctrl+3 { move-column-to-workspace 3; }
      Mod+Ctrl+4 { move-column-to-workspace 4; }
      Mod+Ctrl+5 { move-column-to-workspace 5; }

      Mod+Page_Down { focus-workspace-down; }
      Mod+Page_Up { focus-workspace-up; }

      // Scroll to switch workspaces
      Mod+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }
      Mod+WheelScrollUp cooldown-ms=150 { focus-workspace-up; }

      // Column width
      Mod+R { switch-preset-column-width; }
      Mod+Minus { set-column-width "-10%"; }
      Mod+Equal { set-column-width "+10%"; }

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
      Mod+Shift+E { quit; }
      Mod+Shift+P { power-off-monitors; }
    }
  '';
}
