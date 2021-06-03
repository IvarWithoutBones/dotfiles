{ pkgs, config, ... }:
{
  programs.i3status-rust = {
    enable = true;

    bars.top = {
      blocks = [ {
        block = "custom"; # Ping
        command = "echo \"Ping: $(${pkgs.unixtools.ping}/bin/ping google.com -c 1 | ${pkgs.gnugrep}/bin/grep time= | ${pkgs.coreutils}/bin/cut -d'=' -f4)\"";
        interval = 1;
      } {
        block = "sound";
        format = "{volume}";
      } {
        block = "cpu";
        format = "{utilization}";
        interval = 1;
      } {
        block = "memory";
        format_mem = "{mem_total_used}";
        interval = 1;
      } {
        block = "battery";
        format = "{percentage}";
        interval = 5;
      } {
        block = "time";
        format = "%H:%M:%S";
        interval = 1;
      } ];

      settings = {
        theme.name = "native"; # Use colors provided by i3
        icons.overrides = rec {
          volume_full = "Volume:";
          cpu = "CPU:";
          memory_mem = "Memory:";
          bat = "Battery:";
          time = "";

          # As far as i know, it is not possible to set the label of all status's of these blocks directly.
          bat_charging = bat;
          bat_discharging = bat;
          bat_full = bat;
          volume_empty = volume_full;
          volume_half = volume_full;
          volume_muted = volume_full;
        };
      };
    };
  };
}
