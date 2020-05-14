mod:
{
  "${mod}+Shift+e" = "exec [ \"$(printf \"No\\nYes\" | dmenu -i -p \"Would you like to exit i3?\")\" = \"Yes\" ] && i3-msg exit";
  "${mod}+Shift+r" = "exec i3-msg restart";

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
  "${mod}+v" = "split v";
  "${mod}+s" = "layout stacking";
  "${mod}+w" = "layout tabbed";
  "${mod}+e" = "layout toggle split";
  "${mod}+f" = "fullscreen toggle";
  "${mod}+Shift+space" = "floating toggle";
  "${mod}+space" = "focus mode_toggle";
  "${mod}+a" = "focus parent";
  "${mod}+Shift+q" = "kill";
  "${mod}+1" = "workspace 1";
  "${mod}+2" = "workspace 2: Media";
  "${mod}+3" = "workspace 3: Discord";
  "${mod}+4" = "workspace 4: Spotify";
  "${mod}+5" = "workspace 5: Games";
  "${mod}+6" = "workspace 6";
  "${mod}+7" = "workspace 7";
  "${mod}+8" = "workspace 8";
  "${mod}+9" = "workspace 9";
  "${mod}+0" = "workspace 10: Torrent";
  "${mod}+Shift+1" = "move container to workspace 1";
  "${mod}+Shift+2" = "move container to workspace 2: Media";
  "${mod}+Shift+3" = "move container to workspace 3: Discord";
  "${mod}+Shift+4" = "move container to workspace 4: Spotify";
  "${mod}+Shift+5" = "move container to workspace 5: Games";
  "${mod}+Shift+6" = "move container to workspace 6";
  "${mod}+Shift+7" = "move container to workspace 7";
  "${mod}+Shift+8" = "move container to workspace 8";
  "${mod}+Shift+9" = "move container to workspace 9";
  "${mod}+Shift+0" = "move container to workspace 10: Torrent";
  "${mod}+n" = "move workspace to output right";

  # Open media layout
  "${mod}+Shift+m" = "exec --no-startup-id \"i3-msg 'workspace 2: Media; append_layout /home/ivar/.scripts/16:9_layout.json'\"";

  # Volume control
  "XF86AudioMute" = "exec amixer set Master toggle";
  "XF86AudioRaiseVolume" = "exec amixer set Master 5%+";
  "XF86AudioLowerVolume" = "exec amixer set Master 5%-";

  # Media player control
  "XF86AudioPause" = "exec playerctl play-pause";
  "XF86AudioNext" = "exec playerctl next";
  "XF86AudioPrev" = "exec playerctl previous";
  "XF86AudioStop" = "exec playerctl stop";

  # General programs
  "${mod}+Return" = "exec --no-startup-id st";
  "--release Print" = "exec --no-startup-id maim -su /tmp/screenshot.png && xclip -selection clipboard -t image/png < /tmp/screenshot.png";
  "${mod}+Shift+x" = "exec --no-startup-id /home/ivar/.scripts/lock.sh";
  "${mod}+d" = "exec --no-startup-id dmenu_run";
  "${mod}+Shift+w" = "exec \"i3-msg 'workspace 2: Media; exec qutebrowser --qt-flag ignore-gpu-blacklist --qt-flag enable-gpu-rasterization --qt-flag enable-native-gpu-memory-buffers --qt-flag num-raster-threads=2'\"";
  "${mod}+Shift+n" = "exec appimage-run /home/ivar/misc/electronplayer.AppImage";
  "${mod}+Shift+d" = "exec Discord";
  "${mod}+Shift+s" = "exec \"i3-msg 'workspace 4: Spotify; exec alacritty -e ncspot'\"";
  "${mod}+Shift+t" = "exec transmission-gtk";
}
