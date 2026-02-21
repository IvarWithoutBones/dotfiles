{
  lib,
  config,
  ...
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

  wmConfig =
    isSway:
    let
      # The `class` entries in `assigns`/`floating.criteria` are valid under both X11 and XWayland,
      # but Wayland-native apps exclusively use `app_id`. Generate both entries when running under Sway.
      mkWindowRules =
        rules:
        let
          rulesFor = id: rule: [
            rule
            (rule // { ${id} = ".${rule.${id}}-wrapped"; })
          ];

          mkRule =
            rule:
            (rulesFor "class" (lib.removeAttrs rule [ "app_id" ] // { class = rule.class or rule.app_id; }))
            ++ lib.optional isSway (
              rulesFor "app_id" (lib.removeAttrs rule [ "class" ] // { app_id = rule.app_id or rule.class; })
            );
        in
        lib.flatten (lib.map mkRule rules);
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
          { app_id = "mpv"; }
          { app_id = "org.jellyfin.JellyfinDesktop"; }
          { app_id = "nl.jknaapen.fladder"; }
        ];

        ${workspaces.ws3} = mkWindowRules [
          { app_id = "discord"; }
          { app_id = "element"; }
        ];

        ${workspaces.ws4} = mkWindowRules [
          { app_id = "Psst-gui"; }
          { app_id = "Spotify"; }
          { app_id = "tidal-hifi"; }
        ];

        ${workspaces.ws5} = mkWindowRules [
          { app_id = "steam"; }
          { app_id = "sm64(ex|ex-practice|coopdx)"; }
          { app_id = "Apotris"; }
          { app_id = "factorio"; }
          { app_id = "soh.elf"; }
          { app_id = "Celeste?(-unwrapped)"; }
          { app_id = "EverestSplash-linux"; } # Celeste mod loader
          {
            # Celeste mod manager
            app_id = "love";
            title = "Olympus";
          }
        ];

        ${workspaces.ws10} = mkWindowRules [
          {
            class = "Transmission-gtk";
            app_id = "transmission-gtk";
          }
          { app_id = "transmission-remote-gtk"; }
        ];
      };

      floating.criteria = mkWindowRules [
        {
          # Default to floating windows for everything but the main window.
          app_id = "ghidra-Ghidra";
          title = "^(?!(CodeBrowser.*|Ghidra.*))";
        }
        {
          # See https://github.com/ValveSoftware/steam-for-linux/issues/1040
          app_id = "steam";
          title = "[^Steam]";
        }
        { app_id = "EverestSplash-linux"; }
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
  home.file.".home-manager-graphical-session-wayland" =
    lib.optionalAttrs config.wayland.windowManager.sway.enable
      {
        text = lib.getExe config.wayland.windowManager.sway.package;
      };
}
