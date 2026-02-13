{
  pkgs,
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
          # Temperature
          block = "custom";
          hide_when_empty = true;
          interval = 200;

          command = pkgs.writeShellScript "temperature" ''
            weather="$(${pkgs.curl}/bin/curl -S "wttr.in/?format=1" 2>/dev/null | tr -d "+" | xargs)"
            # This might contain long error codes if the service is down
            (( "''${#weather}" < 10 )) && echo "$weather"
          '';

          click = [
            {
              button = "left";
              cmd = "$TERMINAL --hold -e curl 'https://wttr.in/?F'";
            }
          ];
        }

        {
          # Ping time
          block = "custom";
          hide_when_empty = true;
          interval = 1;

          command = pkgs.writeShellScript "ping-time" ''
            time="$(${pkgs.unixtools.ping}/bin/ping store.steampowered.com -c 1 -w 3 2>/dev/null | ${pkgs.gnugrep}/bin/grep time= | ${pkgs.coreutils}/bin/cut -d'=' -f4)"
            # This might contain long error codes if the service is down
            (( "''${#time}" < 15 )) && (( "''${#time}" > 1 )) && echo "  $time"
          '';
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
          block = "cpu";
          format = "  $utilization.eng(width:3) ";
          interval = 1;
          click = [
            {
              button = "left";
              cmd = "$TERMINAL -e htop";
            }
          ];
        }

        {
          block = "memory";
          format = "  $mem_used.eng(prefix:M,width:3) ";
          interval = 1;
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
