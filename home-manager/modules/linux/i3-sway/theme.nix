{ config
, lib
, pkgs
, wayland
, ...
}:

let
  displayServer = if wayland then "wayland" else "xsession";
  windowManager = if wayland then "sway" else "i3";

  mkDefaultColor = color: attrNames: lib.genAttrs attrNames (name: color);

  mkColor = { ... } @ args:
    mkDefaultColor colors.base [
      "background"
      "border"
      "childBorder"
      "text"
      "indicator"
    ] // { text = colors.text; } // args;

  mkBarColor = { ... } @ args:
    mkDefaultColor colors.base [
      "background"
      "border"
      "text"
    ] // args;

  # A nice looking dark purple theme based off of catppuccin, by https://github.com/kira64xyz
  colors = {
    base = "#12121c";
    highlighted = "#cba6f7";
    text = "#cdd6f4";
    urgent = "#e53935";
  };

  fonts = {
    names = [ "FiraCode Nerd Font" ];
    size = 13.0;
  };
in
{
  fonts.fontconfig.enable = true;

  ${displayServer}.windowManager.${windowManager}.config = {
    inherit fonts;

    colors = {
      unfocused = mkColor { border = colors.highlighted; };
      focusedInactive = mkColor { };
      urgent = mkColor { };
      focused = mkDefaultColor colors.highlighted [
        "background"
        "border"
        "childBorder"
        "indicator"
      ] // { text = colors.base; };
    };

    bars = lib.toList {
      # TODO: move this to bar.nix, this file should only contain the theming
      statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${config.xdg.configHome}/i3status-rust/config-top.toml";
      position = "top";
      inherit fonts;

      colors = {
        background = colors.base;
        focusedWorkspace = mkBarColor { background = colors.highlighted; };
        activeWorkspace = mkBarColor { background = colors.highlighted; };
        inactiveWorkspace = mkBarColor { text = colors.text; };
        urgentWorkspace = mkBarColor { background = colors.urgent; };
      };
    };
  };

  programs.i3status-rust = {
    bars.top.settings.theme.overrides = mkDefaultColor colors.base [
      "warning_bg"
      "good_bg"
      "idle_bg"
      "separator_bg"
    ];
  };
}
