workspaces:

{ config
, lib
, pkgs
, ...
}:

let
  mkKeybindings = modifier: msgCmd: {
    "${modifier}+d" = "exec --no-startup-id ${pkgs.dmenu-configured}/bin/dmenu_run";

    # General programs
    "${modifier}+Return" = "exec --no-startup-id ${config.home.sessionVariables.TERMINAL}";
    "${modifier}+Shift+w" = "exec \"${msgCmd} 'workspace ${workspaces.ws2}; exec ${lib.getExe pkgs.qutebrowser} --qt-flag ignore-gpu-blacklist --qt-flag enable-gpu-rasterization --qt-flag enable-native-gpu-memory-buffers --qt-flag num-raster-threads=2'\"";
    "${modifier}+Shift+d" = "exec ${pkgs.discord-with-openasar}/bin/Discord";
    "${modifier}+Shift+Ctrl+d" = "exec pkill Discord && pkill Discord";
    "${modifier}+Shift+s" = "exec \"${msgCmd} 'workspace ${workspaces.ws4}; exec ${lib.getExe pkgs.tidal-hifi}'\"";
    "${modifier}+Shift+t" = "exec ${pkgs.transmission_4-gtk}/bin/transmission-gtk";

    # Navigation
    "${modifier}+h" = "focus left";
    "${modifier}+l" = "focus right";
    "${modifier}+k" = "focus up";
    "${modifier}+j" = "focus down";
    "${modifier}+Shift+h" = "move left";
    "${modifier}+Shift+l" = "move right";
    "${modifier}+Shift+k" = "move up";
    "${modifier}+Shift+j" = "move down";
    "${modifier}+Ctrl+h" = "resize shrink width 10 px or 10 ppt";
    "${modifier}+Ctrl+l" = "resize grow width 10 px or 10 ppt";
    "${modifier}+Ctrl+k" = "resize shrink height 10 px or 10 ppt";
    "${modifier}+Ctrl+j" = "resize grow height 10 px or 10 ppt";
    "${modifier}+Shift+Ctrl+h" = "split h";
    "${modifier}+n" = "move workspace to output right";
    "${modifier}+v" = "split v";
    "${modifier}+s" = "layout stacking";
    "${modifier}+w" = "layout tabbed";
    "${modifier}+e" = "layout toggle split";
    "${modifier}+f" = "fullscreen toggle";
    "${modifier}+Shift+space" = "floating toggle";
    "${modifier}+space" = "focus mode_toggle";
    "${modifier}+a" = "focus parent";
    "${modifier}+Shift+q" = "kill";
    "${modifier}+1" = "workspace ${workspaces.ws1}";
    "${modifier}+2" = "workspace ${workspaces.ws2}";
    "${modifier}+3" = "workspace ${workspaces.ws3}";
    "${modifier}+4" = "workspace ${workspaces.ws4}";
    "${modifier}+5" = "workspace ${workspaces.ws5}";
    "${modifier}+6" = "workspace ${workspaces.ws6}";
    "${modifier}+7" = "workspace ${workspaces.ws7}";
    "${modifier}+8" = "workspace ${workspaces.ws8}";
    "${modifier}+9" = "workspace ${workspaces.ws9}";
    "${modifier}+0" = "workspace ${workspaces.ws10}";
    "${modifier}+Shift+1" = "move container to workspace ${workspaces.ws1}";
    "${modifier}+Shift+2" = "move container to workspace ${workspaces.ws2}";
    "${modifier}+Shift+3" = "move container to workspace ${workspaces.ws3}";
    "${modifier}+Shift+4" = "move container to workspace ${workspaces.ws4}";
    "${modifier}+Shift+5" = "move container to workspace ${workspaces.ws5}";
    "${modifier}+Shift+6" = "move container to workspace ${workspaces.ws6}";
    "${modifier}+Shift+7" = "move container to workspace ${workspaces.ws7}";
    "${modifier}+Shift+8" = "move container to workspace ${workspaces.ws8}";
    "${modifier}+Shift+9" = "move container to workspace ${workspaces.ws9}";
    "${modifier}+Shift+0" = "move container to workspace ${workspaces.ws10}";

    # Volume control
    "XF86AudioRaiseVolume" = "exec ${lib.getExe pkgs.pamixer} --increase 5";
    "XF86AudioLowerVolume" = "exec ${lib.getExe pkgs.pamixer} --decrease 5";
    # Mute both the input and output devices
    "XF86AudioMute" = "exec ${lib.getExe pkgs.pamixer} --toggle-mute && ${lib.getExe pkgs.pamixer} --default-source --toggle-mute";

    # Media player control
    "XF86AudioPause" = "exec ${lib.getExe pkgs.playerctl} play-pause";
    "XF86AudioNext" = "exec ${lib.getExe pkgs.playerctl} next";
    "XF86AudioPrev" = "exec ${lib.getExe pkgs.playerctl} previous";
    "XF86AudioStop" = "exec ${lib.getExe pkgs.playerctl} stop";

    # Brightness control
    "XF86MonBrightnessUp" = "exec ${lib.getExe pkgs.brightnessctl} set 5%+";
    "XF86MonBrightnessDown" = "exec ${lib.getExe pkgs.brightnessctl} set 5%-";
  };

  mkExitBinding = msgCmd: name:
    "exec [ \"$(printf \"No\\nYes\" | ${lib.getExe pkgs.dmenu-configured} -i -p \"Would you like to exit ${name}?\")\" = \"Yes\" ] && ${msgCmd} exit";
in
{
  xsession.windowManager.i3.config.keybindings =
    let
      msgCmd = "${config.xsession.windowManager.i3.package}/bin/i3-msg";
      modifier = config.xsession.windowManager.i3.config.modifier;
    in
    lib.mkIf config.xsession.windowManager.i3.enable ((mkKeybindings modifier msgCmd) // {
      "${modifier}+Shift+e" = mkExitBinding msgCmd "i3";
      "${modifier}+Shift+r" = "exec ${msgCmd} restart";
      "${modifier}+Shift+x" = "exec ${lib.getExe pkgs.i3lock-fancy}";
      "--release Print" = "exec --no-startup-id ${lib.getExe pkgs.maim} -su /tmp/screenshot.png && ${lib.getExe pkgs.xclip} -selection clipboard -t image/png < /tmp/screenshot.png";
    });

  wayland.windowManager.sway.config.keybindings =
    let
      msgCmd = "${config.wayland.windowManager.sway.package}/bin/swaymsg";
      modifier = config.wayland.windowManager.sway.config.modifier;
    in
    lib.mkIf config.wayland.windowManager.sway.enable ((mkKeybindings modifier msgCmd) // {
      "${modifier}+Shift+e" = mkExitBinding msgCmd "sway";
      "${modifier}+Shift+r" = "exec ${msgCmd} reload";
      "${modifier}+Shift+x" = "exec ${lib.getExe pkgs.swaylock-fancy}";
      "--release Print" = "exec --no-startup-id ${lib.getExe pkgs.sway-contrib.grimshot} copy area";
    });
}
