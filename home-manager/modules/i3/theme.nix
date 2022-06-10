{ config
, lib
, pkgs
, ...
}:

let
  # A nice looking dark purple theme made by https://github.com/kira64xyz
  colors = {
    rosewater = "#f5e0dc";
    mauve = "#cba6f7";
    base = "#12121c";
    text = "#cdd6f4";
    urgent = "#e53935";
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
in
{
  xsession.windowManager.i3.config = {
    colors = {
      unfocused = mkColor { border = colors.mauve; text = colors.text; };
      focusedInactive = mkColor { indicator = colors.mauve; };
      urgent = mkColor { text = colors.text; };
      focused = (mkDefaultColor colors.mauve [
        "background"
        "border"
        "childBorder"
        "indicator"
      ]) // { text = colors.text; };
    };

    bars = [{
      # TODO: move this to i3.nix, this file should only contain the colors and the font
      statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${config.xdg.configHome}/i3status-rust/config-top.toml";
      position = "top";

      fonts = {
        names = [ "FiraCode Nerd Font" ];
        size = 10.0;
      };

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
}
