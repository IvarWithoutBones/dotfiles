{ lib
, pkgs
, config
, ...
}:

let
  modifier = "Mod4";

  workspaces = {
    ws1 = "1";
    ws2 = "2: Media";
    ws3 = "3: Chatting";
    ws4 = "4: Music";
    ws5 = "5: Games";
    ws6 = "6";
    ws7 = "7";
    ws8 = "8";
    ws9 = "9";
    ws10 = "10";
    ws11 = "11";
    ws12 = "12";
    ws13 = "13";
    ws14 = "14";
    ws15 = "15";
    ws16 = "16";
    ws17 = "17";
    ws18 = "18";
    ws19 = "19";
    ws20 = "20";
  };

  wmConfig = {
    inherit modifier;
    terminal = config.home.sessionVariables.TERMINAL;
    defaultWorkspace = "workspace ${workspaces.ws1}";

    # Disable default resize mode
    modes = { };

    # Hide titlebars by default
    window.titlebar = false;

    gaps = {
      inner = 4;
      outer = 4;
    };

    assigns = {
      ${workspaces.ws3} = [
        { class = "discord"; }
        { class = "element"; }
      ];
      ${workspaces.ws4} = [
        { class = "Psst-gui"; }
        { class = "Spotify"; }
        { class = "tidal-hifi"; }
      ];
      ${workspaces.ws5} = [
        { class = "steam"; }
        { class = "sm64(ex|ex-practice|coopdx)"; }
        { class = "Celeste?(-unwrapped)"; }
        { class = "EverestSplash-linux"; } # Celeste mod manager
      ];
    };

    floating.criteria = [
      # Default to floating windows for everything but the main window.
      { class = "steam"; title = "[^Steam]"; } # See https://github.com/ValveSoftware/steam-for-linux/issues/1040
      { class = "ghidra-Ghidra"; title = "^(?!(CodeBrowser.*|Ghidra.*))"; }
    ];
  };

  screenTemp = {
    latitude = "52.1";
    longitude = "5.2";
    low = "3000";
    high = "6500";
  };
in
{
  imports = [
    ./bar.nix
    ./theme.nix
    ./lockscreen.nix
    ((import ./keybindings.nix) workspaces)
  ];

  xsession = lib.mkIf config.xsession.windowManager.i3.enable {
    enable = true;
    scriptPath = ".home-manager-graphical-session-x11";

    windowManager.i3.config = wmConfig // {
      assigns = wmConfig.assigns or { } // {
        ${workspaces.ws10} = wmConfig.assigns.${workspaces.ws10} or [ ] ++ [
          { class = "Transmission-gtk"; } # Needs to be set with `class` on X11 but `app_id` on Wayland
        ];
      };

      startup = wmConfig.startup or [ ] ++ [
        # Set the screen color temperature based on time of day
        { command = "--no-startup-id ${lib.getExe pkgs.redshift} -l ${screenTemp.latitude}:${screenTemp.longitude} -t ${screenTemp.high}K:${screenTemp.low}K"; always = false; }
      ];
    };
  };

  wayland.windowManager.sway = lib.mkIf config.wayland.windowManager.sway.enable {
    # Create a systemd target (`sway-session.target`) so that other services can depend on the sway session.
    systemd.enable = true;
    wrapperFeatures.gtk = true;

    config = wmConfig // {
      assigns = wmConfig.assigns or { } // {
        ${workspaces.ws10} = wmConfig.assigns.${workspaces.ws10} or [ ] ++ [
          { app_id = "transmission-gtk"; } # Needs to be set with `class` on X11 but `app_id` on Wayland
        ];
      };

      startup = wmConfig.startup or [ ] ++ [
        # Set the screen color temperature based on time of day
        { command = "--no-startup-id ${lib.getExe pkgs.wlsunset} -l ${screenTemp.latitude} -L ${screenTemp.longitude} -t ${screenTemp.low} -T ${screenTemp.high}"; always = false; }
      ];
    };
  };

  # Generate a script to start the wayland compositor, used by the login manager
  home.file.".home-manager-graphical-session-wayland" = lib.optionalAttrs config.wayland.windowManager.sway.enable {
    text = lib.getExe config.wayland.windowManager.sway.package;
  };
}
