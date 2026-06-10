{
  pkgs,
  config,
  lib,
  ...
}:

let
  # A small script to print an emoji based on the time of day
  timeEmoji = pkgs.writeShellScript "time-emoji" ''
    HOUR=$(date +'%H')

    if (( $HOUR > 5 && $HOUR < 12 )); then
      echo " "
    elif (( $HOUR >= 12 && $HOUR < 21 )); then
      echo " "
    elif (( $HOUR >= 21 && $HOUR <= 23 )); then
      echo " "
    elif (( $HOUR > 23 || $HOUR <= 5 )); then
      echo "🌙"
    fi
  '';
in
{
  programs.i3status-rust = {
    enable = true;

    bars.top = {
      blocks = [
        {
          # Music
          block = "music";
          player = [
            "spotify"
            "psst"
            "tidal-hifi"
            "io.github.nokse22.high-tide"
            "io.github.lullabyX.sone"
          ];
          format = "{ $icon $combo.str(max_w:50,rot_interval:0.25) }|";
          theme_overrides.info_bg.link = "idle_bg"; # Disable darkened background
          icons_overrides.music = "󰝚";
          click = [
            {
              button = "left";
              action = "prev";
            }
            {
              button = "right";
              action = "next";
            }
            {
              button = "middle";
              action = "play_pause";
            }
          ];
        }

        {
          block = "weather";
          autolocate = true;
          autolocate_interval = 600; # Update location every 10 minutes
          service.name = "metno";
          format = " $icon_ffin $temp_ffin.eng(width:3) ";
          format_alt = " $location - $icon_ffin $temp_ffin $weather_verbose_ffin -  $wind_kmh_ffin km/h $direction_ffin -  $humidity_ffin ";
          click = [
            {
              button = "right";
              cmd = "${lib.getExe config.xdg.terminal-exec.package} --hold -- ${lib.getExe pkgs.bash} -c '${lib.getExe pkgs.curl} \"https://wttr.in/?F\"; read'";
            }
          ];
        }

        {
          block = "sound";
          format = " $icon $volume.eng(width:3) ";
          show_volume_when_muted = true;
          click = [
            {
              button = "left";
              cmd = "${pkgs.pavucontrol}/bin/pavucontrol";
            }
          ];

          icons_overrides = {
            volume_muted = "";
            volume = [
              ""
              ""
              ""
            ];
          };
        }

        {
          block = "backlight";
          format = " $icon $brightness.eng(width:3) ";
          missing_format = ""; # Hide the block if no backlight is detected
        }

        {
          block = "battery";
          format = " $icon $percentage ";
          full_format = " $icon $percentage ";
          charging_format = " $icon $percentage ";
          empty_format = " $icon $percentage ";
          not_charging_format = " $icon $percentage ";
          missing_format = ""; # Hide the block if there is no battery detected.

          # Use the default background regardless of state
          theme_overrides = {
            good_bg.link = "idle_bg";
            warning_bg.link = "idle_bg";
            critical_bg.link = "idle_bg";
            info_bg.link = "idle_bg";
          };

          icons_overrides = {
            bat = [
              "󰁺"
              "󰁻"
              "󰁼"
              "󰁽"
              "󰁾"
              "󰁿"
              "󰂀"
              "󰂁"
              "󰂂"
              "󰁹"
            ];

            bat_charging = [
              "󰢜"
              "󰂆"
              "󰂇"
              "󰂈"
              "󰢝"
              "󰂉"
              "󰢞"
              "󰂊"
              "󰂋"
              "󰂅"
            ];
          };
        }

        {
          # Network icon, changes based on connection type and signal strength.
          block = "net";
          merge_with_next = true;
          format = " $icon ";
          format_alt = " $icon ";
          inactive_format = "";
          missing_format = "";
          icons_overrides.net_wired = "";
        }

        {
          # Ping time
          block = "custom";
          hide_when_empty = true;
          interval = 1;

          command = pkgs.writeShellScript "ping-time" ''
            output="$(${lib.getExe pkgs.unixtools.ping} store.steampowered.com -c 1 -w 1 2>/dev/null | ${lib.getExe pkgs.gnugrep} "time=" | ${lib.getExe' pkgs.coreutils "cut"} -d '=' -f 4)"
            (( "''${#output}" > 15 )) || (( "''${#output}" < 1 )) && exit 0

            time="$(printf "%.1f" "$(cut -d " " -f 1 <<< "$output")")"
            unit="$(cut -d " " -f 2 <<< "$output")"
            (( "''${#time}" > 4 )) && time="$(printf "%.0f" "$time")"
            (( "''${#time}" > 5 )) && time="99999"
            printf "%-5s%2s" "$time" "$unit"
          '';
        }

        {
          # Upload/download speeds
          block = "net";
          interval = 1;
          format = " ^icon_net_down $speed_down.eng(prefix:K,width:4) ^icon_net_up $speed_up.eng(prefix:K,width:4) ";
          format_alt = " $icon {$signal_strength $ssid $frequency|Wired connection} via $device ";
          inactive_format = "";
          missing_format = "";

          click = [
            {
              button = "middle";
              cmd = "${lib.getExe pkgs.xdg-terminal-exec} --hold -- ${lib.getExe pkgs.bash} -c '${lib.getExe' pkgs.iproute2 "ip"} addr; read'";
            }
            {
              button = "right";
              cmd = pkgs.writeShellScript "network-menu" ''
                if command -v impala &>/dev/null; then
                  ${lib.getExe pkgs.xdg-terminal-exec} -- impala
                else
                  ${lib.getExe pkgs.libnotify} --urgency=critical --expire-time=5000 -- "Network" "Cannot configure network without impala."
                fi
              '';
            }
          ];
        }

        {
          block = "disk_iostats";
          format = "  $speed_read.eng(prefix:K,width:4)  $speed_write.eng(prefix:K,width:4) ";
          interval = 1;
        }

        {
          block = "cpu";
          format = "  $utilization.eng(width:3) ";
          interval = 1;
          click = [
            {
              button = "left";
              cmd = "${lib.getExe config.xdg.terminal-exec.package} -- ${lib.getExe pkgs.htop} --sort-key=PERCENT_CPU";
            }
          ];
        }

        {
          block = "memory";
          format = "  $mem_used.eng(prefix:M,width:3) ";
          interval = 1;
          click = [
            {
              button = "left";
              cmd = "${lib.getExe config.xdg.terminal-exec.package} -- ${lib.getExe pkgs.htop} --sort-key=PERCENT_MEM";
            }
          ];
        }

        {
          # Time block, but with an emoji referring to the time of day
          block = "custom";
          command = "echo \"$(${timeEmoji}) $(date +'%H:%M:%S')\"";
          interval = 1;
        }
      ];

      settings = {
        icons.icons = "material-nf"; # Enable nerd-fonts icons
      };
    };
  };
}
