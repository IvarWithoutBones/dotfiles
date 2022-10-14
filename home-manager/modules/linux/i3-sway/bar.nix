{ lib
, pkgs
, config
, hardware
, ...
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
          # Display the currently playing song from an MPRIS instance
          block = "custom";
          command = "${pkgs.mpris-statusbar}/bin/mpris-statusbar";
          hide_when_empty = true;
          interval = 1;
        }
        {
          # Temperature
          block = "custom";
          command = pkgs.writeShellScript "temperature" ''
            weather="$(${pkgs.curl}/bin/curl -S "wttr.in/?format=1" 2>/dev/null | tr -d "+" | xargs)"
            # This might contain long error codes if the service is down
            (( "''${#weather}" < 10 )) && echo "$weather"
          '';
          on_click = "$TERMINAL --hold -e curl 'https://wttr.in/?F'";
          hide_when_empty = true;
          interval = 200;
        }
        {
          # Ping time
          block = "custom";
          command = pkgs.writeShellScript "ping-time" ''
            time="$(${pkgs.unixtools.ping}/bin/ping store.steampowered.com -c 1 -w 1 2>/dev/null | ${pkgs.gnugrep}/bin/grep time= | ${pkgs.coreutils}/bin/cut -d'=' -f4)"
            # This might contain long error codes if the service is down
            (( "''${#time}" < 15 )) && (( "''${#time}" > 1 )) && echo "  $time"
          '';
          hide_when_empty = true;
          interval = 1;
        }
        {
          block = "sound";
          format = "{volume}";
          on_click = "${pkgs.pavucontrol}/bin/pavucontrol";
        }
        {
          block = "cpu";
          format = "{utilization}";
          on_click = "$TERMINAL -e htop";
          interval = 1;
        }
        {
          block = "memory";
          format_mem = "{mem_used}";
          interval = 1;
        }
        {
          # Time block, but with an emoji refering to the time of day
          block = "custom";
          command = "echo \"$(${timeEmoji}) $(date +'%H:%M:%S')\"";
          interval = 1;
        }
      ] ++ lib.optionals (hardware.battery or false) [rec {
        block = "battery";
        interval = 10;
        format = " {percentage}";
        full_format = format;
      }];

      settings = {
        icons.overrides = {
          volume_full = "";
          volume_half = "墳";
          volume_empty = "";
          volume_muted = "";
          bat_charging = "";
          bat_quarter = "";
          bat_half = "";
          bat_three_quarters = "";
          bat_full = "";
          bat_empty = "";
          cpu = "";
          memory_mem = "";
          bat = "Battery:";
        };
      };
    };
  };
}
