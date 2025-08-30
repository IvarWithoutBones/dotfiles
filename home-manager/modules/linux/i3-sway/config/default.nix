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

  startup = [
    { command = "--no-startup-id ${pkgs.alsa-utils}/bin/amixer set Master 35%"; always = false; }
    { command = "--no-startup-id ${pkgs.redshift}/bin/redshift -l 50.77083:3.57361 -t 6500K:3000K"; always = false; }
  ];

  wmConfig = {
    inherit startup modifier;
    terminal = config.home.sessionVariables.TERMINAL;
    defaultWorkspace = "workspace ${workspaces.ws1}";

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
        startup = startup ++ [
          # Tray icon application that disables auto-sleep while certain apps are running
          { command = "--no-startup-id ${pkgs.caffeine-ng}/bin/caffeine"; always = false; }
        ];
      };
    };
  };

  wayland.windowManager.sway = lib.mkIf config.wayland.windowManager.sway.enable {
    config = wmConfig;
    wrapperFeatures.gtk = true;
  };

  # Generate a script to start the wayland compositor, used by the login manager
  home.file.".home-manager-graphical-session-wayland" = lib.optionalAttrs config.wayland.windowManager.sway.enable {
    text = lib.getExe config.wayland.windowManager.sway.package;
  };
}
