{ lib
, pkgs
, config
, ...
}:

let
  mod = "Mod4";

  workspaces = {
    ws1 = "1";
    ws2 = "2: Media";
    ws3 = "3: Discord";
    ws4 = "4: Music";
    ws5 = "5: Games";
    ws6 = "6";
    ws7 = "7";
    ws8 = "8";
    ws9 = "9";
    ws10 = "10";
  };
in
{
  imports = [
    ./bar.nix
    ./theme.nix
  ];

  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;

    config = {
      defaultWorkspace = "workspace ${workspaces.ws1}";
      modifier = mod;
      keybindings = import ./keybindings.nix { inherit config pkgs mod workspaces; };

      gaps = {
        inner = 4;
        outer = 4;
      };

      # Disable default resize mode
      modes = { };

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
        "${workspaces.ws2}" = [{ class = "electronplayer"; }];
        "${workspaces.ws3}" = [{ class = "discord"; }];
        "${workspaces.ws10}" = [{ class = "Transmission-gtk"; }];
        "${workspaces.ws5}" = [{ class = "Steam"; }];
      };

      floating.criteria = [
        { class = "Steam"; title = "Friends List"; }
      ];
    };
  };
}
