{ pkgs, config, ... }: 

let 
  mod = "Mod4";

  workspaces = {
    ws1 = "1";
    ws2 = "2: Media";
    ws3 = "3: Discord";
    ws4 = "4: Music";
    ws5 = "5";
    ws6 = "6";
    ws7 = "7";
    ws8 = "8";
    ws9 = "9";
    ws10 = "10";
  };

  # Colors
  backgroundColor = "#2f343f";
  textColor = "#ffffff";
  inactiveTextColor = "#676e7d";
in {
  imports = [
    ./bar.nix
  ];

  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;

    config = {
      modifier = mod;
      keybindings = import ./keybindings.nix { inherit config pkgs mod workspaces; };
      fonts = {
        names = [ "Liberation Sans" ];
        size = 10.0;
      };
      defaultWorkspace = "workspace ${workspaces.ws1}";

      gaps = {
        inner = 4;
        outer = 4;
      };

      # Disable default resize mode
      modes = {};

      terminal = config.home.sessionVariables.TERMINAL;

      window.commands = [
        { command = "border pixel 1"; criteria.class = "^.*"; }
        { command = "move to workspace ${workspaces.ws4}"; criteria.class = "Spotify"; }
      ];

      startup = [
        { command = "--no-startup-id ${pkgs.alsaUtils}/bin/amixer set Master 35%"; always = false; }
        { command = "--no-startup-id ${pkgs.xorg.xmodmap}/bin/xmodmap -e 'remove Lock = Caps_Lock' -e 'keysym Caps_Lock = Escape'"; always = true; }
        { command = "--no-startup-id ${pkgs.redshift}/bin/redshift -l 50.77083:3.57361 -t 6500K:3000K"; always = false; }
        { command = "--no-startup-id ${pkgs.xwallpaper}/bin/xwallpaper --daemon --zoom ~/.config/wallpapers/spirited_away.png"; always = false; }
      ];

      assigns = {
        "${workspaces.ws2}" = [ { class = "electronplayer"; } ];
        "${workspaces.ws3}" = [ { class = "discord"; } ];
        "${workspaces.ws10}" = [ { class = "Transmission-gtk"; } ];
      };

      colors = {
        focused = { background = "#81848c"; border = "#81848c"; childBorder = "#81848c"; text = textColor; indicator = "#81848c"; };
        focusedInactive = { background = backgroundColor; border = backgroundColor; childBorder = backgroundColor; text = inactiveTextColor; indicator = backgroundColor; };
        unfocused = { background = backgroundColor; border = backgroundColor; childBorder = backgroundColor; text = inactiveTextColor; indicator = backgroundColor; };
        urgent = { background = "#e53935"; border = "e53935"; childBorder = "e53935"; text = textColor; indicator = backgroundColor; };
      };

      bars = [ {
        statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${config.xdg.configHome}/i3status-rust/config-top.toml";
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
      } ];
    };
  }; 
}
