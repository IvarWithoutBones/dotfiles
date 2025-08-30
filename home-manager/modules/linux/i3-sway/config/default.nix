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
  };

  wmConfig = {
    inherit modifier;
    terminal = config.home.sessionVariables.TERMINAL;
    defaultWorkspace = "workspace ${workspaces.ws1}";

    startup = [
      # Tray icon application that disables auto-sleep while certain apps are running
      { command = "--no-startup-id ${lib.getExe pkgs.caffeine-ng}"; always = false; }
      # Set the default volume to 35%
      { command = "--no-startup-id ${pkgs.alsa-utils}/bin/amixer set Master 35%"; always = false; }
    ];

    # Disable default resize mode
    modes = { };

    gaps = {
      inner = 4;
      outer = 4;
    };

    assigns = {
      "${workspaces.ws3}" = [
        { class = "discord"; }
        { class = "element"; }
      ];
      "${workspaces.ws4}" = [
        { class = "Psst-gui"; }
        { class = "Spotify"; }
        { class = "tidal-hifi"; }
      ];
      "${workspaces.ws10}" = [{ class = "Transmission-gtk"; }];
      "${workspaces.ws5}" = [{ class = "steam"; }];
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

    windowManager.i3 = {
      package = pkgs.i3-gaps;
      config = wmConfig // {
        startup = wmConfig.startup ++ [
          { command = "--no-startup-id ${lib.getExe pkgs.redshift} -l ${screenTemp.latitude}:${screenTemp.longitude} -t ${screenTemp.high}K:${screenTemp.low}K"; always = false; }
        ];
      };
    };
  };

  wayland.windowManager.sway = lib.mkIf config.wayland.windowManager.sway.enable {
    wrapperFeatures.gtk = true;
    config = wmConfig // {
      startup = wmConfig.startup ++ [
        { command = "--no-startup-id ${lib.getExe pkgs.wlsunset} -l ${screenTemp.latitude} -L ${screenTemp.longitude} -t ${screenTemp.low} -T ${screenTemp.high}"; always = false; }
      ];
    };
  };

  # Generate a script to start the wayland compositor, used by the login manager
  home.file.".home-manager-graphical-session-wayland" = lib.optionalAttrs config.wayland.windowManager.sway.enable {
    text = lib.getExe config.wayland.windowManager.sway.package;
  };
}
