{ pkgs, ... }: {

services.dunst = {
  enable = true;

  settings = {
    global = {
      monitor = 0;
      geometry = "300x5-30+20";
      shrink = false;
      notification_height = 0;
      separator_height = 2;
      padding = 8;
      horizontal_padding = 8;
      frame_width = 3;
      color = "#ffffff";
      frame_color = "#565d6d";
      separator_color = "#565d6d";
      font = "System San Francisco Display 8";
      line_height = 0;
      markup = "full";
      format = "<b>%s</b>\n%b";
      alignment = "left";
      show_age_threshold = 60;
      word_wrap = true;
      ignore_newline = false;
      stack_duplicates = true;
      hide_duplicate_count = false;
      sticky_history = true;
      history_length = 20;
      always_run_script = true;
      title = "Dunst";
      class = "Dunst";
      startup_notification = false;
      force_xinerama = false;
    };

    expertimental.per_monitor_dpi = false;

    shortcuts = {
      close = "ctrl+space";
      close_all = "ctrl+shift+space";
      history = "ctrl+grave";
      context = "ctrl+shift+period";
    };

    urgency_low = {
      background = "#2f343f";
      foreground = "#ffffff";
      timeout = 10;
    };
    urgency_normal = {
      background = "#2f343f";
      foreground = "#ffffff";
      timeout = 10;
    };
    urgency_critical = {
      background = "#2f343f";
      foreground = "#ffffff";
      timeout = 10;
    };
  };
}; }
