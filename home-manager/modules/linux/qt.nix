{
  config,
  lib,
  pkgs,
  ...
}:

let
  qtctSettings = {
    Appearance = {
      style = "kvantum";
      icon_theme = "Arc";
      standard_dialogs = "xdgdesktopportal";
    };
  }
  // lib.optionalAttrs config.fonts.fontconfig.enable {
    Fonts = {
      fixed = "\"${lib.head config.fonts.fontconfig.defaultFonts.monospace},13\"";
      general = "\"${lib.head config.fonts.fontconfig.defaultFonts.sansSerif},13\"";
    };
  };
in
{
  qt = {
    enable = true;

    platformTheme.name = "qtct";
    qt5ctSettings = qtctSettings;
    qt6ctSettings = qtctSettings;

    style.name = "kvantum";
    kvantum = {
      enable = true;
      settings.General.theme = "catppuccin-mocha-mauve";
      themes = [
        (pkgs.catppuccin-kvantum.override {
          variant = "mocha";
          accent = "mauve";
        })
      ];
    };
  };

  home.packages = [ pkgs.arc-icon-theme ];
}
