{ pkgs, backgroundColor, textColor, inactiveTextColor }:

let
  # Could not get `extraConfig` to work with i3blocks
  blocksConf = pkgs.writeText "i3blocks.conf" ''
    # Global properties
    separator_block_width=10
    markup=none

    # Ping time
    [ping_time]
    command=${pkgs.unixtools.ping}/bin/ping google.com -c 1 | ${pkgs.gnugrep}/bin/grep time= | ${pkgs.coreutils}/bin/cut -d'=' -f4
    label=Ping:
    interval=1

    # Volume indicator
    [volume]
    command=zsh $HOME/.scripts/i3blocks/volume.sh
    # Whitespace is intentional, it is required for spacing.
    label=Volume: 
    interval=1

    # CPU usage
    [cpu_usage]
    command=PATH=${pkgs.lib.makeBinPath [ pkgs.sysstat ]} ${pkgs.perl}/bin/perl $HOME/.scripts/i3blocks/cpu_usage.perl
    interval=2
    min_width=100.00%
    separator=false

    # Memory usage
    [memory]
    command=${pkgs.coreutils}/bin/echo $(${pkgs.toybox}/bin/free -h | ${pkgs.busybox}/bin/awk '/^Mem:/ {print $3}')
    interval=2
    min_width=100.00%
    separator=false

    # Battery usage
    [battery_usage]
    command=${pkgs.coreutils}/bin/echo $(${pkgs.coreutils}/bin/cat /sys/class/power_supply/BAT0/capacity)%
    interval=2

    # Date Time
    [time]
    command=${pkgs.coreutils}/bin/date '+%H:%M:%S'
    interval=1
  '';
in {
  statusCommand = "${pkgs.i3blocks}/bin/i3blocks -c ${blocksConf}";
  position = "top";

  fonts = {
    names = [ "Liberation Sans" ];
    size = 10.0;
  };

  colors = {
    background = backgroundColor;
    separator = "757575";
    focusedWorkspace = { background = backgroundColor; border = backgroundColor; text = textColor; };
    activeWorkspace = { background = backgroundColor; border = backgroundColor; text = textColor; };
    inactiveWorkspace = { background = backgroundColor; border = backgroundColor; text = inactiveTextColor; };
    urgentWorkspace = { background = "#e53935"; border = "e53935"; text = textColor; };
  };
}
