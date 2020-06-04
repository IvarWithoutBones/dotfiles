pkgs: let
  keyBinds = import ./keybindings.nix;

  # Colors
  backgroundColor = "#202020";
  textColor = "#ffffff";
  inactiveTextColor = "#676e7d";

  cfg = {
    pkgs = pkgs;
    mod = "Mod4";
    workspaces = {
      ws1 = "1";
      ws2 = "2: Media";
      ws3 = "3: Discord";
      ws4 = "4";
      ws5 = "5";
      ws6 = "6";
      ws7 = "7";
      ws8 = "8";
      ws9 = "9";
      ws10 = "10";
    };
  };
in
{
  package = pkgs.i3-gaps;
  enable = true;

  config = {
    modifier = cfg.mod;
    keybindings = keyBinds cfg;
    fonts = [ "Liberation Sans 10" ];

    gaps = {
      inner = 4;
      outer = 4;
    };

    # Disable default resize mode
    modes = {};

    terminal = "st";

    window.commands = [
      { command = "border pixel 1"; criteria = { class = "^.*"; }; }
      { command = "move to workspace ${cfg.workspaces.ws4}"; criteria = { class = "Spotify"; }; }
    ];

    startup = [
      { command = "--no-startup-id i3-msg workspace ${cfg.workspaces.ws1}"; always = false; } # Dirty but otherwise it defaults to the last one
      { command = "--no-startup-id amixer set Master 35%"; always = false; }
      { command = "--no-startup-id ${pkgs.xorg.xmodmap}/bin/xmodmap -e 'remove Lock = Caps_Lock' -e 'keysym Caps_Lock = Escape'"; always = true; }
      { command = "--no-startup-id ${pkgs.redshift}/bin/redshift -l 50.77083:3.57361"; always = false; }
      { command = "--no-startup-id ${pkgs.xlibs.xrandr}/bin/xrandr --output HDMI-0 --mode 1280x1024 --pos 4720x570 --output DP-0 --mode 3440x1440 --pos 1280x0 --primary"; always = true; }
      { command = "--no-startup-id ~/.local/bin/xwallpaper --daemon --zoom ~/.config/wallpapers/latenight_woods.png"; always = false; } # xwallpaper is not yet in nixpkgs, tho i've opened an PR: https://github.com/NixOS/nixpkgs/pull/87753
    ];

    assigns = {
      "${cfg.workspaces.ws2}" = [ { class = "electronplayer"; } ];
      "${cfg.workspaces.ws3}" = [ { class = "discord"; } ];
      "${cfg.workspaces.ws10}" = [ { class = "Transmission-gtk"; } ];
    };

    colors = {
      focused = { background = "#81848c"; border = "#81848c"; childBorder = "#81848c"; text = textColor; indicator = "#81848c"; };
      focusedInactive = { background = backgroundColor; border = backgroundColor; childBorder = backgroundColor; text = inactiveTextColor; indicator = backgroundColor; };
      unfocused = { background = backgroundColor; border = backgroundColor; childBorder = backgroundColor; text = inactiveTextColor; indicator = backgroundColor; };
      urgent = { background = "#e53935"; border = "e53935"; childBorder = "e53935"; text = textColor; indicator = backgroundColor; };
    };

    bars = [ { 
      statusCommand = "${pkgs.i3blocks}/bin/i3blocks -c ~/.config/i3/i3blocks.conf"; #TODO: nix-ify this config file when home-manager implements that
      fonts = [ "Liberation Sans 10" ];
      position = "top";
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
}
