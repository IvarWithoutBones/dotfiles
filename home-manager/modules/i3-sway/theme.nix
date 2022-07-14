{ config
, lib
, pkgs
, wayland
, ...
}:

let
  # A nice looking dark purple theme based off of catppuccin made by https://github.com/kira64xyz
  colors = {
    rosewater = "#f5e0dc";
    mauve = "#cba6f7";
    base = "#12121c";
    text = "#cdd6f4";
    urgent = "#e53935";
  };

  fonts = {
    names = [ "FiraCode Nerd Font" ];
    size = 10.0;
  };

  mkDefaultColor = color: attrNames: lib.genAttrs attrNames (name: color);

  mkColor = { ... } @ args:
    (mkDefaultColor colors.base [
      "background"
      "border"
      "childBorder"
      "text"
      "indicator"
    ]) // args;

  mkBarColor = { ... } @ args:
    (mkDefaultColor colors.base [
      "background"
      "border"
      "text"
    ]) // args;

  displayServer = if wayland then "wayland" else "xsession";
  windowManager = if wayland then "sway" else "i3";
in
{
  fonts.fontconfig.enable = true;

  ${displayServer}.windowManager.${windowManager}.config = {
    inherit fonts;

    colors = {
      unfocused = mkColor { border = colors.mauve; text = colors.text; };
      focusedInactive = mkColor { indicator = colors.mauve; };
      urgent = mkColor { text = colors.text; };
      focused = (mkDefaultColor colors.mauve [
        "background"
        "border"
        "childBorder"
        "indicator"
      ]) // { text = colors.base; };
    };

    bars = [{
      # TODO: move this to i3.nix, this file should only contain the colors and the font
      statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${config.xdg.configHome}/i3status-rust/config-top.toml";
      position = "top";
      inherit fonts;

      colors = {
        background = colors.base;
        focusedWorkspace = mkBarColor { background = colors.mauve; };
        urgentWorkspace = mkBarColor { background = colors.urgent; };
        inactiveWorkspace = mkBarColor { text = colors.text; };
        activeWorkspace = mkBarColor { };
      };
    }];
  };

  programs.i3status-rust = {
    bars.top.settings = {
      theme.overrides = mkDefaultColor colors.base [
        "warning_bg"
        "good_bg"
        "idle_bg"
        "separator_bg"
      ];

      icons.overrides = {
        volume_full = "";
        volume_half = "墳";
        volume_empty = "";
        volume_muted = "";
        bat_charging = "";
        bat_quarter = "";
        bat_half = "";
        bat_three_quarters = "";
        bat_full = "";
        bat_empty = "";
        cpu = "";
        memory_mem = "";
        bat = "Battery:";
      };
    };
  };

  gtk = {
    enable = true;

    theme = {
      name = "Catppuccin-purple-dark";
      package = pkgs.catppuccin-gtk;
    };

    iconTheme = {
      name = "Arc";
      package = pkgs.arc-icon-theme;
    };

    cursorTheme = {
      name = "capitaine-cursors";
      package = pkgs.capitaine-cursors;
    };
  };
}
