{
  pkgs,
  config,
  ...
}:

{
  gtk = {
    enable = true;
    gtk4.theme = config.gtk.theme;

    theme = {
      name = "Colloid-Purple-Dark-Catppuccin";
      package = pkgs.colloid-gtk-theme.override {
        tweaks = [ "catppuccin" ];
        themeVariants = [ "purple" ]; # Matches Catppuccin's mauve
        colorVariants = [ "dark" ];
      };
    };

    iconTheme = {
      name = "Arc";
      package = pkgs.arc-icon-theme;
    };
  };
}
