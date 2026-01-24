{ lib
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

  wmConfig = isSway:
    let
      # The `class` entries in `assigns`/`floating.criteria` are valid under both X11 and XWayland,
      # but Wayland-native apps exclusively use `app_id`. Generate both entries when running under Sway.
      mkWindowRules = rules: lib.flatten (lib.map
        (rule: [ (lib.removeAttrs rule [ "app_id" ]) ] ++ lib.optionals isSway [
          ({ app_id = rule.class; } // lib.removeAttrs rule [ "class" ])
        ])
        rules);
    in
    {
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
        ${workspaces.ws2} = mkWindowRules [
          { class = "mpv"; }
          { class = "org.jellyfin.JellyfinDesktop"; }
        ];

        ${workspaces.ws3} = mkWindowRules [
          { class = "discord"; }
          { class = "element"; }
        ];

        ${workspaces.ws4} = mkWindowRules [
          { class = "Psst-gui"; }
          { class = "Spotify"; }
          { class = "tidal-hifi"; }
        ];

        ${workspaces.ws5} = mkWindowRules [
          { class = "steam"; }
          { class = "sm64(ex|ex-practice|coopdx)"; }
          { class = ".Apotris-wrapped"; }
          { class = "Apotris"; }
          { class = "Celeste?(-unwrapped)"; }
          { class = "EverestSplash-linux"; } # Celeste mod loader
          { class = "love"; title = "Olympus"; } # Celeste mod manager
        ];

        ${workspaces.ws10} = mkWindowRules [
          { class = "Transmission-gtk"; app_id = "transmission-gtk"; }
        ];
      };

      floating.criteria = mkWindowRules [
        # Default to floating windows for everything but the main window.
        { class = "steam"; title = "[^Steam]"; } # See https://github.com/ValveSoftware/steam-for-linux/issues/1040
        { class = "ghidra-Ghidra"; title = "^(?!(CodeBrowser.*|Ghidra.*))"; }
        { class = "EverestSplash-linux"; }
      ];
    };
in
{
  imports = [
    ./bar.nix
    ./theme.nix
    ./lockscreen.nix
    ./display-temperature.nix
    ./input.nix
    ((import ./keybindings.nix) workspaces)
  ];

  xsession = lib.mkIf config.xsession.windowManager.i3.enable {
    enable = true;
    scriptPath = ".home-manager-graphical-session-x11";
    windowManager.i3.config = wmConfig false;
  };

  wayland.windowManager.sway = lib.mkIf config.wayland.windowManager.sway.enable {
    config = wmConfig true;
  };

  # Generate a script to start the wayland compositor, used by the login manager
  home.file.".home-manager-graphical-session-wayland" = lib.optionalAttrs config.wayland.windowManager.sway.enable {
    text = lib.getExe config.wayland.windowManager.sway.package;
  };
}
