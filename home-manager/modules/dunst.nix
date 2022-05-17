{ pkgs, config, ... }:

{
  services.dunst = {
    enable = true;

    settings = {
      global = {
        color = "#ffffff";
        frame_color = "#565d6d";
        separator_color = "#565d6d";
        font = "FiraCode Nerd Font";
      };
  
      # TODO: doesn't seem to work?
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
 };
}
