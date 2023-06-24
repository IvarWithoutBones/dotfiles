{ pkgs
, lib
, config
, mod
, workspaces
, windowManager
}:

{
  "${mod}+Shift+e" = "exec [ \"$(printf \"No\\nYes\" | ${pkgs.dmenu-configured}/bin/dmenu -i -p \"Would you like to exit i3?\")\" = \"Yes\" ] && ${pkgs.i3-gaps}/bin/i3-msg exit";
  "${mod}+d" = "exec --no-startup-id ${pkgs.dmenu-configured}/bin/dmenu_run";

  # General programs
  "${mod}+Return" = "exec --no-startup-id ${config.home.sessionVariables.TERMINAL}";
  "${mod}+Shift+w" = "exec \"${pkgs.i3-gaps}/bin/i3-msg 'workspace ${workspaces.ws2}; exec ${pkgs.qutebrowser}/bin/qutebrowser --qt-flag ignore-gpu-blacklist --qt-flag enable-gpu-rasterization --qt-flag enable-native-gpu-memory-buffers --qt-flag num-raster-threads=2'\"";
  "${mod}+Shift+d" = "exec ${pkgs.discord-with-openasar}/bin/Discord";
  "${mod}+Shift+Ctrl+d" = "exec pkill Discord && pkill Discord";
  "${mod}+Shift+s" = "exec \"${pkgs.i3-gaps}/bin/i3-msg 'workspace ${workspaces.ws4}; exec ${pkgs.psst}/bin/psst-gui'\"";
  "${mod}+Shift+t" = "exec ${pkgs.transmission-gtk}/bin/transmission-gtk";
  "${mod}+Shift+n" = "exec ${pkgs.electronplayer}/bin/electronplayer";

  # Navigation
  "${mod}+h" = "focus left";
  "${mod}+l" = "focus right";
  "${mod}+k" = "focus up";
  "${mod}+j" = "focus down";
  "${mod}+Shift+h" = "move left";
  "${mod}+Shift+l" = "move right";
  "${mod}+Shift+k" = "move up";
  "${mod}+Shift+j" = "move down";
  "${mod}+Ctrl+h" = "resize shrink width 10 px or 10 ppt";
  "${mod}+Ctrl+l" = "resize grow width 10 px or 10 ppt";
  "${mod}+Ctrl+k" = "resize shrink height 10 px or 10 ppt";
  "${mod}+Ctrl+j" = "resize grow height 10 px or 10 ppt";
  "${mod}+Shift+Ctrl" = "split h";
  "${mod}+n" = "move workspace to output right";
  "${mod}+v" = "split v";
  "${mod}+s" = "layout stacking";
  "${mod}+w" = "layout tabbed";
  "${mod}+e" = "layout toggle split";
  "${mod}+f" = "fullscreen toggle";
  "${mod}+Shift+space" = "floating toggle";
  "${mod}+space" = "focus mode_toggle";
  "${mod}+a" = "focus parent";
  "${mod}+Shift+q" = "kill";
  "${mod}+1" = "workspace ${workspaces.ws1}";
  "${mod}+2" = "workspace ${workspaces.ws2}";
  "${mod}+3" = "workspace ${workspaces.ws3}";
  "${mod}+4" = "workspace ${workspaces.ws4}";
  "${mod}+5" = "workspace ${workspaces.ws5}";
  "${mod}+6" = "workspace ${workspaces.ws6}";
  "${mod}+7" = "workspace ${workspaces.ws7}";
  "${mod}+8" = "workspace ${workspaces.ws8}";
  "${mod}+9" = "workspace ${workspaces.ws9}";
  "${mod}+0" = "workspace ${workspaces.ws10}";
  "${mod}+Shift+1" = "move container to workspace ${workspaces.ws1}";
  "${mod}+Shift+2" = "move container to workspace ${workspaces.ws2}";
  "${mod}+Shift+3" = "move container to workspace ${workspaces.ws3}";
  "${mod}+Shift+4" = "move container to workspace ${workspaces.ws4}";
  "${mod}+Shift+5" = "move container to workspace ${workspaces.ws5}";
  "${mod}+Shift+6" = "move container to workspace ${workspaces.ws6}";
  "${mod}+Shift+7" = "move container to workspace ${workspaces.ws7}";
  "${mod}+Shift+8" = "move container to workspace ${workspaces.ws8}";
  "${mod}+Shift+9" = "move container to workspace ${workspaces.ws9}";
  "${mod}+Shift+0" = "move container to workspace ${workspaces.ws10}";

  # Volume control
  "XF86AudioRaiseVolume" = "exec ${pkgs.pamixer}/bin/pamixer --increase 5";
  "XF86AudioLowerVolume" = "exec ${pkgs.pamixer}/bin/pamixer --decrease 5";
  # Mute both the input and output devices
  "XF86AudioMute" = "exec ${pkgs.pamixer}/bin/pamixer --toggle-mute && ${pkgs.pamixer}/bin/pamixer --default-source --toggle-mute";

  # Media player control
  "XF86AudioPause" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
  "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
  "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";
  "XF86AudioStop" = "exec ${pkgs.playerctl}/bin/playerctl stop";

  # Brightness control
  "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 10%+";
  "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 10%-";
} // lib.optionalAttrs (windowManager == "i3") {
  "${mod}+Shift+r" = "exec i3-msg restart";
  "${mod}+Shift+x" = "exec ${pkgs.i3lock-fancy}/bin/i3lock-fancy";
  "--release Print" = "exec --no-startup-id ${pkgs.maim}/bin/maim -su /tmp/screenshot.png && ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png < /tmp/screenshot.png";
} // lib.optionalAttrs (windowManager == "sway") {
  "${mod}+Shift+r" = "exec swaymsg reload";
  "--release Print" = "exec --no-startup-id ${pkgs.sway-contrib.grimshot}/bin/grimshot copy area";
  "${mod}+Shift+x" = "exec ${pkgs.swaylock-fancy}/bin/swaylock-fancy";
}
