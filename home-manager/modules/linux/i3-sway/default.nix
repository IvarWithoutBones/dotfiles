{ lib
, pkgs
, config
, wayland
, hardware
, ...
}:

let
  mod = "Mod4";

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

  displayServer = if wayland then "wayland" else "xsession";
  windowManager = if wayland then "sway" else "i3";
in
{
  imports = [
    ./bar.nix
    ./theme.nix
    ./lockscreen.nix
  ];

  ${displayServer} = {
    windowManager.${windowManager} = {
      enable = true;
      package = lib.mkIf (windowManager == "i3") pkgs.i3-gaps;

      config = {
        keybindings = import ./keybindings.nix { inherit config pkgs mod workspaces windowManager lib; };
        terminal = config.home.sessionVariables.TERMINAL;
        defaultWorkspace = "workspace ${workspaces.ws1}";
        modifier = mod;

        # Disable default resize mode
        modes = { };

        gaps = {
          inner = 4;
          outer = 4;
        };

        window.commands = [
          # Disable titlebar
          { command = "border pixel 1"; criteria.class = "^.*"; }
        ];

        startup = [
          { command = "--no-startup-id ${pkgs.alsa-utils}/bin/amixer set Master 35%"; always = false; }
          { command = "--no-startup-id ${pkgs.redshift}/bin/redshift -l 50.77083:3.57361 -t 6500K:3000K"; always = false; }
        ] ++ lib.optionals (displayServer == "wayland") [
          { command = "--no-startup-id ${pkgs.swaybg}/bin/swaybg -i ${config.xdg.configHome}/wallpapers/spirited_away.png"; always = false; }
        ] ++ lib.optionals (displayServer == "xsession") [
          { command = "--no-startup-id ${pkgs.xwallpaper}/bin/xwallpaper --daemon --zoom ${config.xdg.configHome}/wallpapers/spirited_away.png"; always = false; }
        ];

        assigns = {
          "${workspaces.ws2}" = [{ class = "electronplayer"; }];
          "${workspaces.ws3}" = [
            { class = "discord"; }
            { class = "Cinny"; }
          ];
          "${workspaces.ws4}" = [{ class = "Psst-gui"; }];
          "${workspaces.ws10}" = [{ class = "Transmission-gtk"; }];
          "${workspaces.ws5}" = [{ class = "Steam"; }];
        };

        floating.criteria = [
          { class = "Steam"; title = "Friends List"; }
        ];
      } // lib.optionalAttrs (windowManager == "sway") {
        # Bind capslock to escape, and vise versa
        input."*" = {
          xkb_layout = "eu";
          xkb_options = "caps:swapescape";
          repeat_delay = "300";
          repeat_rate = "50";
        };
      };
    } // lib.optionalAttrs (windowManager == "sway") {
      wrapperFeatures.gtk = true;
    };
  } // lib.optionalAttrs (displayServer == "xsession") {
    enable = true;
    scriptPath = ".hm-graphical-session";
  };

  home.file.".hm-graphical-session".text = lib.optionalString (windowManager == "sway") ''
    ${lib.optionalString (hardware.gpu or "" == "nvidia") ''
      # Required for propietary nvidia drivers
      export GBM_BACKEND=nvidia-drm_gbm.so __GLX_VENDOR_LIBRARY_NAME=nvidia WLR_NO_HARDWARE_CURSORS=1 MOZ_ENABLE_WAYLAND=1 SDL_VIDEODRIVER=wayland
    ''}

    ${pkgs.sway}/bin/sway ${lib.optionalString (hardware.gpu or "" == "nvidia") "--unsupported-gpu"}
  '';
}
